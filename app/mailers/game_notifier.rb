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

    @recipients = [game.challenged, game.challenger].select { |p|
      p.wants_challenge_completed_notifications?
    }.map(&:email)

    return if @recipients.empty?

    mail(
      :to => @recipients,
      :subject => I18n.t('game.notifications.completed_game.subject')
    )
  end
end
