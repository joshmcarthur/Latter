FactoryGirl.define do
  factory :web_hook do
    destination { "http://www.example.com" }
    event { 'game_completed' }
  end
end
