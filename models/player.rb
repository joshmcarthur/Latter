class Player
  include DataMapper::Resource
  include Gravtastic
  CHALLENGABLE_SENSITIVITY = 1


  #these constants are used to calculate how many points a
  #player has accrued in the last n days
  WIN_POINTS = 3
  THRASH_POINTS = 1
  THRASH_MARGIN = 12
  CONSOLATION_POINTS = 1
  CONSOLATION_MARGIN = 2
  POINT_TIME_LIMIT = 30

  property :id, Serial
  property :name, String, :required => true
  property :email, String, :required => true, :unique_index => true
  property :calculated_ranking, Integer

  has_gravatar
  has n, :won_challenges, 'Challenge', :child_key => [:winner_id], :parent_key => [:id]
  has n, :initiated_challenges, 'Challenge', :child_key => [:from_player_id], :parent_key => [:id]
  has n, :challenged_challenges, 'Challenge', :child_key => [:to_player_id], :parent_key => [:id]

  def self.recalculate_rankings
    Player.all.sort_by { |player| player.points }.reverse.each_with_index do |player, i|
      player.calculated_ranking = i+1
      player.save
    end
  end

  def challenges
    (initiated_challenges.all + challenged_challenges.all)
  end

  def recent_challenges
    challenges.all(
      :completed => true,
      :created_at.gte => Date.today - POINT_TIME_LIMIT
    )
  end

  def can_challenge?(another_player)
    (self.ranking - another_player.ranking).abs <= Player::CHALLENGABLE_SENSITIVITY
  end

  def in_progress_challenges(another_player)
    (
      initiated_challenges.all(
        :to_player_id => another_player.id,
        :completed => false) +
      challenged_challenges.all(
        :from_player_id => another_player.id,
        :completed => false
      )
    ).uniq
  end

  def challenged_by?(another_player)
    !self.challenges.select do |challenge|
      challenge.from_player_id == another_player.id or challenge.to_player_id == another_player.id
    end.empty?
  end

  def total_wins
    self.won_challenges.length
  end

  def points
    total = 0
    self.recent_challenges.each do |challenge|
      if challenge.winner?(self)
        total += WIN_POINTS
        total += THRASH_POINTS if challenge.winning_margin >= THRASH_MARGIN
      elsif challenge.loser?(self) && challenge.winning_margin <= CONSOLATION_MARGIN
        total += CONSOLATION_POINTS
      end
    end

    total * (winning_percentage(false) / 100.to_f)
  end

  def winning_percentage(return_string = true)
    if self.challenges.all(:completed => true).length > 0
      percentage = ((self.total_wins.to_f / self.challenges.all(:completed => true).length.to_f) * 100).to_i
      return_string ? percentage.to_s.concat("%") : percentage
    else
      return_string ? "0%" : 0
    end
  end

  def ranking
    self.calculated_ranking || 0
  end

  def ranking_as_percentage
    ((ranking.to_f / Player.count.to_f) * 100).to_i.to_s.concat("%")
  end
end
