class Data::TracksController < ApplicationController
  before_filter :require_login
  layout false

  def index
    available_source_ids = Source.available_ids_for_user(current_user)

    # select tracks
    options = get_options_from_params
    tracks_box = select_tracks(available_source_ids, options)

    # render
    render json: {
      page: options[:page],
      per_page: options[:per_page],
      total: tracks_box[:total],
      models: tracks_box[:tracks]
    }.to_json(
      methods: [:available],
      except: [:search_vector]
    )
  end


private


  #
  #  Parameter processing
  #
  def get_options_from_params
    options = {
      filter: clean_up_filter_value(params[:filter]),
      page: params[:page].to_i,
      per_page: params[:per_page].to_i,
      sort_by: params[:sort_by].try(:to_sym),
      sort_direction: params[:sort_direction].try(:upcase),
      select_favourites: (params[:favourites] == "true"),
      playlist: params[:playlist]
    }

    # add options that depend on other options
    options = options.merge(
      offset: (options[:page] - 1) * options[:per_page]
    )

    # return
    options
  end


  def clean_up_filter_value(value)
    value.strip
      .gsub(/([\&\(\)]+)|(\A[\|\ ]+)|([!\|\ ]+\z)|(!!+)/, "")
      .gsub(/ {2,}/, " ")
      .gsub(/!\ /, "!")
      .gsub(/ \|\|+ /, " | ")
      .gsub(/(?<!\||!)\ (?!\|)/, " & ")
  end


  #
  #  Select tracks
  #
  def select_tracks(available_source_ids, options)
    filter = !options[:filter].blank?
    select_favourites = options[:select_favourites]
    playlist = get_playlist(options[:playlist])

    # check
    if available_source_ids.empty? and !select_favourites
      return { tracks: [], total: 0 }
    end

    # conditions
    conditions, condition_arguments = [], []

    if select_favourites
      conditions << "user_id = ?"
      condition_arguments << current_user.id
    else
      conditions << "source_id IN (?)"
      condition_arguments << available_source_ids
    end

    if filter
      conditions << "search_vector @@ to_tsquery('english', ?)"
      condition_arguments << options[:filter]
    end

    if playlist.is_a?(Playlist)
      conditions.unshift "#{select_favourites ? 'track_id' : 'id'} IN (?)"
      condition_arguments.unshift playlist.track_ids
    elsif playlist.is_a?(String)
      conditions.push "location LIKE (?)"
      condition_arguments.push "#{playlist}%"
    end

    # bundle conditions
    condition_sql = conditions.join(" AND ")
    conditions = [condition_sql] + condition_arguments.compact

    # next
    args = [conditions, available_source_ids, options]
    if select_favourites then select_favourited_tracks(*args)
    else select_default_tracks(*args)
    end
  end


  def select_default_tracks(conditions, available_source_ids, options)
    order = get_sql_for_order(options[:sort_by], options[:sort_direction])

    # get tracks
    tracks = Track.find(:all, {
      offset: options[:offset],
      limit: options[:per_page],
      conditions: conditions,
      order: order
    })

    total = if options[:offset] == 0 && tracks.length < options[:per_page]
      tracks.length
    else
      Track.count(conditions: conditions)
    end

    # return
    { tracks: tracks, total: total }
  end


  def select_favourited_tracks(conditions, available_source_ids, options)
    order = get_sql_for_order(options[:sort_by], options[:sort_direction])

    # get favourites
    find_arguments = {
      offset: options[:offset],
      limit: options[:per_page],
      conditions: conditions,
      order: order
    }

    favourites = Favourite.find(:all, find_arguments)
    total = Favourite.count(conditions: conditions)

    # process favourites
    track_ids = []
    tracks_placeholder = favourites.map { |f| f.id }

    source_ids = current_user.sources.all.map { |s| s.id }
    unavailable_source_ids = source_ids - available_source_ids

    favourites.each_with_index do |f, idx|
      if f.track_id
        track_ids << f.track_id
      else
        imaginary_track = Track.new({
          title: f.title,
          artist: f.artist,
          album: f.album,
          tracknr: 0,
          genre: ""
        })

        imaginary_track.favourite_id = f.id
        imaginary_track.available = false

        index = tracks_placeholder.index(f.id)
        tracks_placeholder[index] = imaginary_track
      end
    end

    # get unavailable tracks
    _unavailable_tracks = Track.where(id: track_ids, source_id: unavailable_source_ids)
    _unavailable_tracks.each do |ut|
      ut.available = false

      index = tracks_placeholder.index(ut.favourite_id)
      tracks_placeholder[index] = ut

      track_ids.delete(ut.id)
    end

    # get available tracks
    _tracks = Track.where(id: track_ids, source_id: available_source_ids)
    _tracks.each do |t|
      index = tracks_placeholder.index(t.favourite_id)
      tracks_placeholder[index] = t
    end

    # clean up placeholder
    tracks_placeholder = tracks_placeholder.map do |t|
      t.is_a?(Fixnum) ? nil : t
    end.compact

    # return
    { tracks: tracks_placeholder, total: total }
  end


  #
  #  Select tracks / Helpers
  #
  def get_playlist(playlist)
    if playlist
      if playlist.index("/") then playlist
      elsif playlist.to_i === 0 then false
      else Playlist.find(playlist.to_i)
      end
    end
  end


  def get_sql_for_order(sort_by, direction="ASC")
    order = case sort_by
    when :title
      "LOWER(title), tracknr, LOWER(artist), LOWER(album)"
    when :album
      "LOWER(album), tracknr, LOWER(artist), LOWER(title)"
    else
      "LOWER(artist), LOWER(album), tracknr, LOWER(title)"
    end

    if direction == "DESC"
      order.split(", ").map { |o| "#{o} DESC" }.join(", ")
    else
      order
    end
  end

end
