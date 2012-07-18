class TracksController < ApplicationController
  before_filter :require_login
  layout false

  def index
    available_sources = current_user.sources.where(activated: true).all
    available_sources = available_sources.keep_if do |source|
      source.available?
    end

    available_source_ids = available_sources.map { |source| source.id }

    # filter, pagination, order, etc.
    options = {
      filter: params[:filter],
      page: params[:page].to_i,
      per_page: params[:per_page].to_i,
      sort_by: params[:sort_by].try(:to_sym),
      sort_direction: params[:sort_direction].upcase,
    }

    options[:offset] = (options[:page] - 1) * options[:per_page]

    # select tracks
    tracks = if params[:favourites] == "true"
      []
    else
      select_tracks(available_source_ids, options)
    end

    # render
    render json: {
      page: options[:page],
      per_page: options[:per_page],
      total: tracks.length,
      models: tracks
    }.to_json(methods: [:favourite, :available])
  end


private


  def select_tracks(available_source_ids, options)
    filter = !options[:filter].blank?

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
    condition_sql  = "source_id IN (?)"
    condition_sql += " AND search_vector @@ to_tsquery('english', ?)" if filter

    condition_arguments  = [available_source_ids]
    condition_arguments += [options[:filter].strip.gsub(" ", " | ")] if filter

    conditions = [condition_sql] + condition_arguments

    # grab tracks
    tracks = Track.find(:all,
      offset: options[:offset],
      limit: options[:per_page],
      conditions: conditions,
      order: order
    )

    # user's favourites
    favourites = current_user.favourites.all

    # which are favourites?
    tracks.each do |t|
      favourite_matches = favourites.select do |f|
        f.track_title == t.title and f.track_artist == t.artist
      end

      t.favourite = favourite_matches.length > 0
      favourites = favourites - favourite_matches
    end

    # give it to me
    return tracks
  end


  def select_favourite_tracks(available_source_ids, options)
    filter = options[:filter].blank?
    tracks = []

    # loop over favourites
    favourites.each do |f|
      favourite_track = Track.where(
        "title = ? AND artist = ?", f.track_title, f.track_artist
      ).first

      unless favourite_track
        tracks << Track.new({
          title: f.track_title,
          artist: f.track_artist,
          album: "",
          tracknr: "",
          genre: "",
          favourite: true,
          available: false
        })
      else
        tracks << favourite_track
      end
    end

    # sort
    tracks = case options[:sort_by]
    when :title
      tracks.sort_by { |t| [t.title.downcase, t.tracknr, t.artist.downcase, t.album.downcase] }
    when :album
      tracks.sort_by { |t| [t.album.downcase, t.tracknr, t.artist.downcase, t.title.downcase] }
    else
      tracks.sort_by { |t| [t.artist.downcase, t.album.downcase, t.tracknr, t.title.downcase] }
    end

    # reverse?
    tracks.reverse! if options[:sort_direction] == "DESC"

    # slice
    tracks = tracks.slice(options[:offset], options[:per_page])

    # give it to me
    return tracks
  end

end
