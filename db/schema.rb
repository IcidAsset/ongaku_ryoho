# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120714202127) do

  create_table "favourites", :force => true do |t|
    t.string   "artist"
    t.string   "title"
    t.string   "album"
    t.integer  "tracknr",       :default => 0
    t.integer  "user_id"
    t.integer  "track_id"
    t.tsvector "search_vector"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "favourites", ["search_vector"], :name => "favourites_search_index"
  add_index "favourites", ["track_id"], :name => "index_favourites_on_track_id"
  add_index "favourites", ["user_id"], :name => "index_favourites_on_user_id"

  create_table "sources", :force => true do |t|
    t.boolean  "activated",     :default => false
    t.string   "configuration", :default => "--- {}\n"
    t.string   "status",        :default => ""
    t.string   "name"
    t.string   "type"
    t.integer  "user_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  add_index "sources", ["user_id"], :name => "index_sources_on_user_id"

  create_table "tracks", :force => true do |t|
    t.string   "artist"
    t.string   "title"
    t.string   "album"
    t.string   "genre"
    t.integer  "tracknr"
    t.integer  "year"
    t.string   "filename"
    t.string   "location"
    t.string   "url"
    t.integer  "source_id"
    t.integer  "favourite_id"
    t.tsvector "search_vector"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "tracks", ["favourite_id"], :name => "index_tracks_on_favourite_id"
  add_index "tracks", ["search_vector"], :name => "tracks_search_index"
  add_index "tracks", ["source_id"], :name => "index_tracks_on_source_id"

  create_table "users", :force => true do |t|
    t.string   "email",                        :null => false
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "remember_me_token"
    t.datetime "remember_me_token_expires_at"
  end

  add_index "users", ["remember_me_token"], :name => "index_users_on_remember_me_token"

end
