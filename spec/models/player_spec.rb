require 'spec_helper'

describe Player do

  subject do
    FactoryGirl.build(:player)
  end

  it "should create a valid player" do
    subject.save
    expect(subject).to be_persisted
  end

  it "should not create an invalid player" do
    subject.name = ""
    subject.save
    expect(subject).not_to be_persisted
  end

  it "should set a default password when the player is created" do
    expect(subject.password).to be_blank
    subject.save
    expect(subject.password).not_to be_blank
  end

  it "should set an authentication token when the player is saved" do
    expect(subject.authentication_token).to be_blank
    subject.save
    expect(subject.authentication_token).not_to be_blank
  end

  describe "Gravatar" do
    it "should have a gravatar url" do
      expect(subject.gravatar_url).to include "gravatar.com"
    end
  end

  describe "Associations" do
    it "should have challenged games" do
      game = FactoryGirl.create(:game, :challenged => subject)
      expect(subject.challenged_games).to eq [game]
    end

    it "should have challenger games" do
      game = FactoryGirl.create(:game, :challenger => subject)
      expect(subject.challenger_games).to eq [game]
    end

    it "should have won games" do
      game = FactoryGirl.create(:game, :challenger => subject, :winner => subject)
      expect(subject.won_games).to eq [game]
    end

    it "should show all completed games" do
      FactoryGirl.create_list(:game, 5, :complete => true, :challenged => subject)
      expect(subject.games(true).size).to eq 5
    end

    it "should show all games" do
      FactoryGirl.create_list(:game, 5, :complete => false, :challenged => subject)
      expect(subject.games.size).to eq 5
    end

    it "should return in progress games for a given player" do
      player = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game, :complete => false, :challenged => player, :challenger => subject)
      expect(subject.in_progress_games(player)).to eq [game]
    end
  end

  describe "Badges" do

    before do
       subject.save
       @badge = FactoryGirl.create(:badge)
       @award = subject.award!(@badge)
       # @award = FactoryGirl.create(:award, :player => subject, :badge => @badge)
    end

    it "should be able to be assigned correctly" do
      expect(@award).to be_valid
      expect(subject.badges).to include { @badge }
      expect(subject.awards).to include { @award }
    end

    it "should not be duplicated unless allowed to be" do
      subject.award!(@badge)
      expect(subject.badges.count).to eq 1
      @badge.allow_duplicates = true
      subject.award!(@badge)
      expect(subject.badges.count).to eq 2
    end

    it "should be removed when awards are destroyed" do
      @award.destroy
      expect(subject.badges).not_to include { @badge }
      expect(subject.awards).not_to include { @award }
    end

  end

  describe "Pro rating" do
    it "should be pro if rating is over the threshold" do
      # Default player rating threshold is 2400
      subject.rating = 2500
      expect(subject.pro_rating?).to be_truthy
    end

    it "should not be pro if rating is not over the threshold" do
      subject.rating = 2000
      expect(subject.pro_rating?).not_to be_truthy
    end
  end

  describe "Starter rating" do
    it "should be a starter if the player has played less than 30 games" do
      games = FactoryGirl.build_list(:game, 29, :challenger => subject)
      allow(subject).to receive(:games).and_return(games)
      expect(subject.starter?).to be_truthy
    end

    it "should not be a starter if the player has played more than 30 games" do
      games = FactoryGirl.build_list(:game, 31, :challenger => subject)
      allow(subject).to receive(:games).and_return(games)
      expect(subject.starter?).not_to be_truthy
    end
  end

  describe "K Factor" do
    it "should return the correct k-factor for a pro player" do
      subject.pro = true
      expect(subject.k_factor).to eq Player::PRO_K_FACTOR
    end

    it "should return the correct k-factor for a starter player" do
      allow(subject).to receive(:starter?).and_return(true)
      expect(subject.k_factor).to eq Player::STARTER_K_FACTOR
    end

    it "should return the default k-factor otherwise" do
      # A player only gets the default when they ARE
      # a starter, but ARE NOT a pro
      allow(subject).to receive(:starter?).and_return(false)
      expect(subject.k_factor).to eq Player::DEFAULT_K_FACTOR
    end
  end

  describe "Rating" do
    it "should change the ranking when a game is completed" do
      game = FactoryGirl.build(:game, :challenged => subject)
      game.complete!(:challenged_score => 21, :challenger_score => 15)
      expect {
        subject.send(:played, game)
      }.to change(subject, :rating)
    end
  end

  describe "Trends" do
    it "should calculate an improving trend" do
      game = FactoryGirl.build(:game, :challenged => subject)
      game.complete!(:challenged_score => 21, :challenger_score => 15)

      expect(subject.trend).to eq :up
    end

    it "should calculate a worsening trend" do
      game = FactoryGirl.build(:game, :challenger => subject)
      game.complete!(:challenged_score => 21, :challenger_score => 15)

      expect(subject.trend).to eq :down
    end

    it "should calculate a same trend" do
      expect(subject.trend).to eq :same
    end
  end

  describe "Default scope" do
    before :each do
      subject.save
    end

    it "should find an active player" do
      expect(Player.all).to include(subject)
    end

    it "should not find an inactive player" do
      subject.active = false
      subject.save

      expect(Player.all).to_not include subject
    end
  end
end
