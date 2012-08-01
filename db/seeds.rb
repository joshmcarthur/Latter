# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Badge.find_or_create_by_name('Silver Bull', image_url: "/badges/silverbull.png", description: "Completed over 140 chargeable hours in a month")
Badge.find_or_create_by_name('Gold Bull', image_url: "/badges/goldbull.png", description: "Completed over 170 chargeable hours in a month")
