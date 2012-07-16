class TracksController < ApplicationController
  before_filter :require_login
  layout false

  def index
    available_sources = current_user.sources.where(activated: true).all
    available_sources = available_sources.keep_if do |source|
      source.available?
    end

    available_source_ids = available_sources.map { |source| source.id }

    # pagination, order, etc.
    options = {
      filter: params[:filter],
      page: params[:page].to_i,
      per_page: params[:per_page].to_i,
      sort_by: params[:sort_by].try(:to_sym),
      sort_direction: params[:sort_direction].upcase
    }

    # select tracks
    tracks = if params[:favourites] == "true"
      favourite_selection(available_source_ids, options)
    else
      default_selection(available_source_ids, options)
    end

    render json: {
      page: options[:page],
      per_page: options[:per_page],
      total: tracks.length,
      models: tracks
    }.to_json(methods: [:favourite, :available])
  end


  # DEPRECATED
    # favourites
    # favourites = current_user.favourites.all
    #
    # tracks.each do |t|
    #   favourite_matches = favourites.select { |f|
    #     f.track_title == t.title and f.track_artist == t.artist
    #   }
    #
    #   t.favourite = favourite_matches.length > 0
    #   t.available = true
    #
    #   favourites = favourites - favourite_matches
    # end
    #
    # if params[:favourites] == "true"
    #   favourite_tracks = tracks.select(&:favourite)
    #
    #   favourites.each do |f|
    #     favourite_tracks << Track.new({
    #       title: f.track_title,
    #       artist: f.track_artist,
    #       album: "",
    #       tracknr: "",
    #       genre: "",
    #       favourite: true,
    #       available: false
    #     })
    #   end
    #
    #   tracks = favourite_tracks
    # end


private


  def default_selection(available_source_ids, options)
    offset = (options[:page] - 1) * options[:per_page]
    limit = options[:per_page]

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
    conditions = if options[:filter].blank?
      { source_id: available_source_ids }
    else
      ["search_vector @@ to_tsquery('english', ?) AND source_id IN (?)",
       options[:filter].strip.gsub(" ", " | "),
       available_source_ids]
    end

    # grab tracks
    tracks = Track.find(:all,
      offset: offset,
      limit: limit,
      conditions: conditions,
      order: order
    )
  end

  def favourite_selection(available_source_ids, options)
  end

end
