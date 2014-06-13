class Api::TracksController < ApplicationController
  before_filter :require_login
  layout false

  def index
    options = get_options_from_params

    # available source ids
    available_source_ids = options[:source_ids]

    # select tracks
    tracks_box = select_tracks(available_source_ids, options)

    only = %w(
      artist title album tracknr filename
      location url id favourite_id source_id created_at
    )

    tracks = tracks_box[:tracks].map do |track|
      attrs = track.attributes.select do |k, v|
        only.include?(k)
      end
      attrs["available"] = track.available
      attrs
    end

    # json
    render json: Oj.dump({
      page: options[:page],
      per_page: options[:per_page],
      total: tracks_box[:total],
      models: tracks
    }, mode: :compat)
  end


private


  #
  #  Parameter processing
  #
  def get_options_from_params
    options = {
      source_ids: clean_up_source_ids(params[:source_ids]),
      filter: get_filter_value(params[:searches]),
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


  def get_filter_value(searches)
    excludes = []

    searches = (searches || []).map do |search_query|
      search_query = view_context.sanitize(search_query)
      search_query = search_query
        .gsub(/\:|\*|\&|\||\'|\"|\+/, "")
        .strip
        .gsub(/^\!+\s*/, "!")
        .gsub(" ", "+")

      if search_query.size == 0
        nil
      elsif search_query[0] == "!"
        search_query = "!" + search_query[1..-1].gsub("!", "")
        excludes << "#{search_query}:*"
        nil
      else
        search_query = search_query.gsub("!", "")
        "#{search_query}:*"
      end
    end.compact

    # filter
    filter = ""
    filter << "(#{searches.join(" | ")})" if searches.length > 0
    filter << " & " if searches.length > 0 && excludes.length > 0
    filter << "(#{excludes.join(" & ")})" if excludes.length > 0
    filter
  end


  def clean_up_source_ids(source_ids)
    user_source_ids = current_user.sources.pluck(:id)
    source_ids.split(",").map do |source_id|
      id = source_id.to_i
      id if id > 0 && user_source_ids.include?(id)
    end.compact
  end


  #
  #  Select tracks
  #
  def select_tracks(available_source_ids, options)
    filter = !options[:filter].blank?
    select_favourites = options[:select_favourites]
    playlist = get_playlist(options[:playlist])

    # table
    if playlist.is_a?(Playlist) or playlist.is_a?(String)
      options[:table] = "tracks"
    elsif select_favourites
      options[:table] = "favourites"
    else
      options[:table] = "tracks"
    end

    table = options[:table]

    # check
    unless available_source_ids
      return { tracks: [], total: 0 }
    end

    # conditions
    conditions, condition_arguments = [], []

    # conditions / basic track selection
    if select_favourites
      if playlist
        # tracks will be selected in the
        # 'select_favourites_tracks_for_playlist' method
      else
        conditions << "#{table}.user_id = ?"
        condition_arguments << current_user.id
      end
    else
      unless playlist.is_a?(Playlist)
        conditions << "#{table}.source_id IN (?)"
        condition_arguments << available_source_ids
      end

      if playlist.is_a?(Playlist)
        conditions.unshift "#{table}.id IN (?)"
        condition_arguments.unshift playlist.track_ids
      elsif playlist.is_a?(String)
        conditions.push "#{table}.location LIKE (?)"
        condition_arguments.push "#{playlist}%"
      end
    end

    # conditions / full text search
    if filter
      conditions << "#{table}.search_vector @@ to_tsquery('english', ?)"
      condition_arguments << options[:filter]
    end

    # bundle conditions
    condition_sql = conditions.join(" AND ")
    conditions = [condition_sql] + condition_arguments.compact
    conditions = Source.send(:sanitize_sql_array, conditions)

    # next
    args = [conditions, available_source_ids, options]

    if select_favourites
      if playlist.is_a?(Playlist) or playlist.is_a?(String)
        args.push(playlist)
        select_favourites_tracks_for_playlist(*args)
      else
        select_favourited_tracks(*args)
      end
    else
      args.push(playlist)
      select_default_tracks(*args)
    end
  end


  def select_default_tracks(conditions, available_source_ids, options, playlist)
    order = get_sql_for_order(options, true, playlist)

    # find args
    find_args = {
      offset: options[:offset],
      limit: options[:per_page],
      conditions: conditions,
      order: order
    }

    # find args / playlist position
    if playlist.is_a?(Playlist) && options[:sort_by] == :position
      find_args[:joins] = :playlists_tracks
    end

    # get tracks
    tracks = Track.find(:all, find_args)

    total = if options[:offset] == 0 && tracks.length < options[:per_page]
      tracks.length
    else
      Track.count(conditions: conditions)
    end

    # playlist / mark unavailable tracks
    if playlist.is_a?(Playlist)
      tracks = tracks.each do |t|
        unless available_source_ids.include?(t.source_id)
          t.available = false
        end

        t
      end
    end

    # return
    { tracks: tracks, total: total }
  end


  def select_favourited_tracks(conditions, available_source_ids, options)
    order = get_sql_for_order(options, false)

    # get favourites
    if order.is_a?(String)
      favourites = Favourite.find(:all, {
        offset: options[:offset],
        limit: options[:per_page],
        conditions: conditions,
        order: order
      })
    else
      favourites = Favourite.find(:all, {
        conditions: conditions
      })
    end

    total = if options[:offset] == 0 && favourites.length < options[:per_page]
      favourites.length
    else
      Favourite.count(conditions: conditions)
    end

    # process favourites
    unavailable_track_ids = []
    track_ids = []
    tracks_placeholder = favourites.map(&:id)

    source_ids = current_user.sources.all.map(&:id)
    unavailable_source_ids = source_ids - available_source_ids

    favourites.each do |f|
      track_id = nil

      unless f.track_ids.keys.empty?
        track_id = get_track_id_from_track_ids_hash(f.track_ids, available_source_ids)
        track_ids << track_id if track_id

        unless track_id
          track_id = get_track_id_from_track_ids_hash(f.track_ids, unavailable_source_ids)
          unavailable_track_ids << track_id if track_id
        end
      end

      unless track_id
        imaginary_track = Track.new({
          title: f.title,
          artist: f.artist,
          album: f.album,
          tracknr: 0,
          genre: "",
          location: "NOT AVAILABLE"
        })

        imaginary_track.favourite_id = f.id
        imaginary_track.available = false

        index = tracks_placeholder.index(f.id)
        tracks_placeholder[index] = imaginary_track
      end
    end

    # get unavailable tracks
    _unavailable_tracks = Track.where(id: unavailable_track_ids)
    _unavailable_tracks.each do |ut|
      ut.available = false

      index = tracks_placeholder.index(ut.favourite_id)
      tracks_placeholder[index] = ut

      track_ids.delete(ut.id)
    end

    # get available tracks
    _tracks = Track.where(id: track_ids)
    _tracks.each do |t|
      index = tracks_placeholder.index(t.favourite_id)
      tracks_placeholder[index] = t
    end

    # clean up placeholder
    tracks_placeholder = tracks_placeholder.map do |t|
      t.is_a?(Fixnum) ? nil : t
    end.compact

    # sort in ruby if needed
    if order.is_a?(Array)
      order_with_lambda = !order[2].nil?

      if order_with_lambda
        the_lambda = order[2]

        tracks_placeholder = tracks_placeholder.sort do |a, b|
          the_lambda.call(a.send(order.first)) <=> the_lambda.call(b.send(order.first))
        end
      else
        tracks_placeholder = tracks_placeholder.sort do |a, b|
          a.send(order.first) <=> b.send(order.first)
        end
      end

      if order[1] == :desc
        tracks_placeholder = tracks_placeholder.reverse
      end
    end

    # return
    { tracks: tracks_placeholder, total: total }
  end


  def select_favourites_tracks_for_playlist(conditions, available_source_ids, options, playlist)
    order = get_sql_for_order(options, false)
    asi_string = available_source_ids.map { |s| "'#{s}'" }.join(",")
    more_conditions = []

    # get favourites
    favourites = if available_source_ids.length === 0
      []
    else
      Favourite.find(:all, {
        conditions: "user_id = #{current_user.id} AND track_ids ?| ARRAY[#{asi_string}]",
        select: "array_to_string(track_ids -> ARRAY[#{asi_string}], ',') AS selected_track_ids"
      })
    end

    # track ids from favourites
    track_ids = favourites.map(&:selected_track_ids)

    # get tracks
    if playlist.is_a?(Playlist)
      track_ids = track_ids.map { |t| t.split(",") }.flatten
      ids = (playlist.track_ids.map(&:to_s) & track_ids).join(",")
      more_conditions << "id IN (#{ids})"
    elsif playlist.is_a?(String)
      ids = (track_ids).join(",")
      more_conditions << "id IN (#{ids})"
      more_conditions << "location LIKE ('#{playlist.gsub("'", "''")}%')"
    end

    # check
    if ids.length == 0
      return { tracks: [], total: 0 }
    end

    # get tracks
    conditions = conditions + " AND " unless conditions.blank?
    conditions = conditions + more_conditions.join(" AND ")

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

    # unavailable tracks
    tracks = tracks.each do |t|
      unless available_source_ids.include?(t.source_id)
        t.available = false
      end

      t
    end

    # return
    { tracks: tracks, total: total }
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


  def get_sql_for_order(options, include_track_number=false, playlist=nil)
    sort_by = options[:sort_by]
    direction = options[:sort_direction]
    table = options[:table]
    other_cols = include_track_number ? " #{table}.tracknr," : ""

    # don't sort on position when it's not available
    if !playlist.is_a?(Playlist) && sort_by == :position
      sort_by = :artist
    end

    # order
    is_not_a_playlist = (options[:playlist] === "false")

    order = case sort_by
    when :date
      if options[:select_favourites] && is_not_a_playlist
        [:created_at, direction.downcase.to_sym]
      else
        "created_at::timestamp::date, LOWER(artist), LOWER(album),#{other_cols} LOWER(title)"
      end
    when :directory
      if options[:select_favourites] && is_not_a_playlist
        [:location, direction.downcase.to_sym, lambda { |location| location.split("/")[-2] }]
      else
        "split_part(location, '/', array_length(regexp_split_to_array(location, E'\/'), 1) - 1)"
      end
    when :location
      if options[:select_favourites] && is_not_a_playlist
        [:location, direction.downcase.to_sym, lambda { |location| location.downcase }]
      else
        "LOWER(location)"
      end
    when :position
      "playlists_tracks.position, LOWER(#{table}.artist), LOWER(#{table}.album),#{other_cols} LOWER(#{table}.title)"
    when :title
      "LOWER(title),#{other_cols} LOWER(artist), LOWER(album)"
    when :album
      "LOWER(album),#{other_cols} LOWER(artist), LOWER(title)"
    else
      "LOWER(artist), LOWER(album),#{other_cols} LOWER(title)"
    end

    # order direction
    if order.is_a?(String) && direction == "DESC"
      order.split(", ").map { |o| "#{o} DESC" }.join(", ")
    else
      order
    end
  end


  def get_track_id_from_track_ids_hash(track_ids, source_ids)
    track_id = nil

    # loop
    source_ids.each do |source_id|
      if ids_array_string = track_ids[source_id.to_s]
        if tid = ids_array_string.split(",").first
          track_id = tid
          break
        end
      end
    end

    # return
    track_id
  end

end
