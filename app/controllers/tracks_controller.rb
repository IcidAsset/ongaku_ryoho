class TracksController < ApplicationController
  before_filter :require_login
  layout false

  def index
    available_sources = current_user.sources.where(activated: true).all
    available_sources.keep_if do |source|
      source.available?
    end

    # available source ids
    available_source_ids = available_sources.map { |source| source.id }

    # filter, pagination, order, etc.
    options = {
      filter: params[:filter],
      page: params[:page].to_i,
      per_page: params[:per_page].to_i,
      sort_by: params[:sort_by].try(:to_sym),
      sort_direction: params[:sort_direction].try(:upcase),
      select_favourites: (params[:favourites] == "true")
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

    # condition sql
    condition_sql = ""
    condition_sql << "source_id IN (?)" unless select_favourites
    condition_sql << (
      (condition_sql.blank? ? "" : " AND ") +
      "search_vector @@ to_tsquery('english', ?)"
    ) if filter

    # condition arguments
    condition_arguments = []
    condition_arguments << available_source_ids unless select_favourites
    condition_arguments << (
      options[:filter].strip.gsub(" ", " | ")
    ) if filter

    # conditions
    conditions = [condition_sql] + condition_arguments.compact

    # grab tracks
    unless select_favourites
      tracks = Track.find(:all, {
        offset: options[:offset],
        limit: options[:per_page],
        conditions: conditions,
        order: order
      })

      total = Track.count(conditions: conditions)

    else
      favourites = Favourite.find(:all, {
        offset: options[:offset],
        limit: options[:per_page],
        conditions: conditions,
        order: order
      })

      total = Favourite.count(conditions: conditions)

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

      _unavailable_tracks = Track.where(id: track_ids, source_id: unavailable_source_ids)
      _unavailable_tracks.each do |ut|
        ut.available = false

        index = tracks_placeholder.index(ut.favourite_id)
        tracks_placeholder[index] = ut

        track_ids.delete(ut.id)
      end

      _tracks = Track.where(id: track_ids, source_id: available_source_ids)
      _tracks.each do |t|
        index = tracks_placeholder.index(t.favourite_id)
        tracks_placeholder[index] = t
      end

      tracks = tracks_placeholder

    end

    # give it to me
    return { tracks: tracks, total: total }
  end

end
