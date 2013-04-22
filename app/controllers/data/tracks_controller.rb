class Data::TracksController < ApplicationController
  before_filter :require_login
  layout false

  def index
    available_source_ids = Source.available_ids_for_user(current_user)

    # filter, pagination, order, etc.
    options = {
      filter: params[:filter],
      page: params[:page].to_i,
      per_page: params[:per_page].to_i,
      sort_by: params[:sort_by].try(:to_sym),
      sort_direction: params[:sort_direction].try(:upcase),
      select_favourites: (params[:favourites] == "true"),
      playlist: params[:playlist]
    }

    # options that depend on other options
    options.merge!({
      offset: (options[:page] - 1) * options[:per_page]
    })

    # select tracks
    tracks_box = select_tracks(available_source_ids, options)
    tracks = tracks_box[:tracks]
    total = tracks_box[:total]

    # render
    render json: {
      page: options[:page],
      per_page: options[:per_page],
      total: total,
      models: tracks
    }.to_json(
      methods: [:available],
      except: [:search_vector]
    )
  end


private


  def select_tracks(available_source_ids, options)
    filter = !options[:filter].blank?
    select_favourites = options[:select_favourites]

    # check
    if available_source_ids.empty? and !select_favourites
      return { tracks: [], total: 0 }
    end

    # playlist
    playlist = if playlist = options[:playlist]
      if playlist.index("/") then playlist
      elsif playlist.to_i === 0 then false
      else Playlist.find(playlist.to_i)
      end
    end

    # filter value
    filter_value = if filter
      options[:filter].strip
        .gsub(/([\&\(\)]+)|(\A[\|\ ]+)|([!\|\ ]+\z)|(!!+)/, "")
        .gsub(/ {2,}/, " ")
        .gsub(/!\ /, "!")
        .gsub(/ \|\|+ /, " | ")
        .gsub(/(?<!\||!)\ (?!\|)/, " & ")
    else
      ""
    end

    # order
    order = case options[:sort_by]
    when :title
      "LOWER(title), tracknr, LOWER(artist), LOWER(album)"
    when :album
      "LOWER(album), tracknr, LOWER(artist), LOWER(title)"
    else
      "LOWER(artist), LOWER(album), tracknr, LOWER(title)"
    end

    # reverse order?
    if options[:sort_direction] == "DESC"
      order = order.split(", ").map { |o| "#{o} DESC" }.join(", ")
    end

    # conditions
    conditions = []
    conditions << "source_id IN (?)" unless select_favourites
    conditions << "search_vector @@ to_tsquery('english', ?)" if filter

    # condition arguments
    condition_arguments = []
    condition_arguments << available_source_ids unless select_favourites
    condition_arguments << filter_value if filter

    # grab tracks
    unless select_favourites
      if playlist.is_a?(Playlist)
        conditions.unshift "id IN (?)"
        condition_arguments.unshift playlist.track_ids
      elsif playlist.is_a?(String)
        conditions << "location LIKE (?)"
        condition_arguments << "#{playlist}%"
      end

      condition_sql = conditions.join(" AND ")
      conditions = [condition_sql] + condition_arguments.compact

      tracks = Track.find(:all, {
        offset: options[:offset],
        limit: options[:per_page],
        conditions: conditions,
        order: order
      })

      total = Track.count(conditions: conditions)

    else
      if playlist.is_a?(Playlist)
        conditions.unshift "track_id IN (?)"
        condition_arguments.unshift playlist.track_ids
      end

      condition_sql = conditions.join(" AND ")
      conditions = [condition_sql] + condition_arguments.compact

      find_arguments = {
        conditions: conditions,
        order: order
      }

      unless playlist
        find_arguments[:offset] = options[:offset]
        find_arguments[:limit] = options[:per_page]
      end

      favourites = Favourite.find(:all, find_arguments)
      total = Favourite.count(conditions: conditions)

      track_ids = []
      tracks_placeholder = favourites.map { |f| f.id }

      source_ids = current_user.sources.all.map { |s| s.id }
      unavailable_source_ids = source_ids - available_source_ids

      favourites.each_with_index do |f, idx|
        if f.track_id
          track_ids << f.track_id
        elsif !playlist
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

      _unavailable_tracks = Track.where(id: track_ids, source_id: unavailable_source_ids)
      _unavailable_tracks.each do |ut|
        ut.available = false

        index = tracks_placeholder.index(ut.favourite_id)
        tracks_placeholder[index] = ut

        track_ids.delete(ut.id)
      end

      _track_conditions = [
        "id in (?) AND source_id in (?)",
        track_ids, available_source_ids
      ]

      if playlist.is_a?(String)
        _track_conditions[0] << " AND location LIKE ?"
        _track_conditions << "#{playlist}%"
      end

      _tracks = Track.where(_track_conditions)
      _tracks.each do |t|
        index = tracks_placeholder.index(t.favourite_id)
        tracks_placeholder[index] = t
      end

      if playlist.is_a?(String)
        tracks_placeholder = tracks_placeholder.map do |t|
          t.is_a?(Fixnum) ? nil : t
        end.compact
      end

      if playlist and tracks_placeholder.size > options[:per_page]
        tracks_placeholder = tracks_placeholder.slice(options[:offset], options[:per_page])
      end

      tracks = tracks_placeholder

    end

    # give it to me
    return { tracks: tracks, total: total }
  end

end
