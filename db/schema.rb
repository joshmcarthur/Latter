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

ActiveRecord::Schema.define(:version => 20120723092950) do

  create_table "activities", :force => true do |t|
    t.text     "message",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "awards", :force => true do |t|
    t.integer  "player_id",  :null => false
    t.integer  "badge_id",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "awards", ["badge_id", "player_id"], :name => "index_awards_on_badge_id_and_player_id", :unique => true
  add_index "awards", ["badge_id"], :name => "index_awards_on_badge_id"
  add_index "awards", ["player_id"], :name => "index_awards_on_player_id"

  create_table "badges", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "imageURL"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "games", :force => true do |t|
    t.integer  "challenger_id",                    :null => false
    t.integer  "challenged_id",                    :null => false
    t.boolean  "complete",      :default => false, :null => false
    t.float    "result"
    t.string   "score"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "winner_id"
  end

  add_index "games", ["challenged_id"], :name => "index_games_on_challenged_id"
  add_index "games", ["challenger_id", "challenged_id"], :name => "index_games_on_challenger_id_and_challenged_id"
  add_index "games", ["challenger_id"], :name => "index_games_on_challenger_id"
  add_index "games", ["complete"], :name => "index_games_on_complete"

  create_table "players", :force => true do |t|
    t.string   "email",                                   :default => "",    :null => false
    t.string   "encrypted_password",                      :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                           :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "name",                                                       :null => false
    t.integer  "rating",                                  :default => 1000,  :null => false
    t.boolean  "pro",                                     :default => false, :null => false
    t.boolean  "starter",                                 :default => true,  :null => false
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.boolean  "changed_password",                        :default => false, :null => false
    t.boolean  "wants_challenge_completed_notifications", :default => true,  :null => false
  end

  add_index "players", ["confirmation_token"], :name => "index_players_on_confirmation_token", :unique => true
  add_index "players", ["email"], :name => "index_players_on_email", :unique => true
  add_index "players", ["reset_password_token"], :name => "index_players_on_reset_password_token", :unique => true

end
