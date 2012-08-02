def sign_in(player)
  
      player.confirmed_at = Time.now
      player.changed_password = true
      player.save!
  
      visit new_player_session_path
      fill_in 'Email', :with => player.email
      fill_in 'Password', :with => player.password
      click_on 'Sign in'
    
end
