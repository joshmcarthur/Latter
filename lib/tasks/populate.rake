namespace :db do
	desc "Fill the database with sample data"
	task populate: :environment do

		15.times do |n|
			FactoryGirl.create(:player)
		end

		player = Player.first
		player.password = "password"
		player.password_confirmation = "password"
    player.confirmed_at = Time.now
    player.changed_password = true
    player.save!

	end
end