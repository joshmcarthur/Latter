def sign_in(player)
  
      player.confirmed_at = Time.now
      player.changed_password = true
      player.save!
  
      visit new_player_session_path
      fill_in 'player_email', :with => player.email
      fill_in 'player_password', :with => player.password
      click_on 'Sign in'
    
end
