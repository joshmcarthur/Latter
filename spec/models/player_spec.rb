require 'spec_helper'

describe Player do

  subject do
    FactoryGirl.build(:player)
  end

  it "should create a valid player" do
    subject.save
    subject.should be_persisted
  end

  it "should not create an invalid player" do
    subject.name = ""
    subject.save
    subject.should_not be_persisted
  end

  it "should set a default password when the player is created" do
    subject.password.should be_blank
    subject.save
    subject.password.should_not be_blank
  end

  it "should set an authentication token when the player is saved" do
    subject.authentication_token.should be_blank
    subject.save
    subject.authentication_token.should_not be_blank
  end

  describe "Gravatar" do
    it "should have a gravatar url" do
      subject.gravatar_url.should include "gravatar.com"
    end
  end

  describe "Associations" do
    it "should have challenged games" do
      game = FactoryGirl.create(:game, :challenged => subject)
      subject.challenged_games.should eq [game]
    end

    it "should have challenger games" do
      game = FactoryGirl.create(:game, :challenger => subject)
      subject.challenger_games.should eq [game]
    end

    it "should have won games" do
      game = FactoryGirl.create(:game, :challenger => subject, :winner => subject)
      subject.won_games.should eq [game]
    end
    
    it "should show all completed games" do
      FactoryGirl.create_list(:game, 5, :complete => true, :challenged => subject)
      subject.games(true).size.should eq 5
    end

    it "should show all games" do
      FactoryGirl.create_list(:game, 5, :complete => false, :challenged => subject)
      subject.games.size.should eq 5
    end

    it "should return in progress games for a given player" do
      player = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game, :complete => false, :challenged => player, :challenger => subject)
      subject.in_progress_games(player).should eq [game]
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
      @award.should be_valid
      subject.badges.should include { @badge }
      subject.awards.should include { @award }
    end

    it "should not be duplicated unless allowed to be" do
      subject.award!(@badge)
      subject.badges.count.should eq 1
      @badge.allow_duplicates = true
      subject.award!(@badge)
      subject.badges.count.should eq 2
    end
    
    it "should be removed when awards are destroyed" do
      @award.destroy
      subject.badges.should_not include { @badge }
      subject.awards.should_not include { @award }
    end

  end

  describe "Pro rating" do
    it "should be pro if rating is over the threshold" do
      # Default player rating threshold is 2400
      subject.rating = 2500
      subject.pro_rating?.should be_true
    end

    it "should not be pro if rating is not over the threshold" do
      subject.rating = 2000
      subject.pro_rating?.should_not be_true
    end
  end

  describe "Starter rating" do
    it "should be a starter if the player has played less than 30 games" do
      games = FactoryGirl.build_list(:game, 29, :challenger => subject)
      subject.stub!(:games).and_return(games)
      subject.starter?.should be_true
    end

    it "should not be a starter if the player has played more than 30 games" do
      games = FactoryGirl.build_list(:game, 31, :challenger => subject)
      subject.stub!(:games).and_return(games)
      subject.starter?.should_not be_true
    end
  end

  describe "K Factor" do
    it "should return the correct k-factor for a pro player" do
      subject.pro = true
      subject.k_factor.should eq Player::PRO_K_FACTOR
    end

    it "should return the correct k-factor for a starter player" do
      subject.stub!(:starter?).and_return(true)
      subject.k_factor.should eq Player::STARTER_K_FACTOR
    end

    it "should return the default k-factor otherwise" do
      # A player only gets the default when they ARE
      # a starter, but ARE NOT a pro
      subject.stub!(:starter?).and_return(false)
      subject.k_factor.should eq Player::DEFAULT_K_FACTOR
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

      subject.trend.should eq :up
    end

    it "should calculate a worsening trend" do
      game = FactoryGirl.build(:game, :challenger => subject)
      game.complete!(:challenged_score => 21, :challenger_score => 15)

      subject.trend.should eq :down
    end

    it "should calculate a same trend" do
      subject.trend.should eq :same
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
