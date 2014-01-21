# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'factory_girl'
FactoryGirl.find_definitions

15.times do |n|
	puts FactoryGirl.create(:player).inspect
end

player = Player.first
player.password = "password"
player.password_confirmation = "password"
player.confirmed_at = Time.now
player.changed_password = true
player.save!
