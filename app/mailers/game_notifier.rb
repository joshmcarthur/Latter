class GameNotifier < ActionMailer::Base
  default from: "notifications@latter.3months.com"

  def new_game(game)
    @game = game
    @preview_text = I18n.t('game.notifications.new_game.preview_text', :challenger => game.challenger.email)

    mail(
      :to => game.challenged.email,
      :subject => I18n.t('game.notifications.new_game.subject')
    )
  end

  def completed_game(game)
    @game = game
    @preview_text = I18n.t('game.notifications.completed_game.preview_text')

    mail(
      :to => [game.challenged.email, game.challenger.email],
      :subject => I18n.t('game.notifications.completed_game.subject')
    )
  end
end
