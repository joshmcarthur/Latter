# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Badge.find_or_create_by_name('Silver Bull', image_url: "/images/badges/silverbull.png", description: "Completed over 140 chargeable hours in a month")
Badge.find_or_create_by_name('Gold Bull', image_url: "/images/badges/goldbull.png", description: "Completed over 170 chargeable hours in a month")

15.times do |n|
	FactoryGirl.create(:player)
end

player = Player.first
player.password = "password"
player.password_confirmation = "password"
player.confirmed_at = Time.now
player.changed_password = true
player.save!
