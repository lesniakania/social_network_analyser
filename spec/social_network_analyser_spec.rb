require 'social_network_analyser'

describe SocialNetworkAnalyser do
  before(:each) do
    @user_ids = (1..5).map { |id| DB[:users].insert }
  end

  describe "degree centrality" do
    it "should compute outdegree centrality properly" do
      user_id = DB[:users].insert
      @user_ids.each { |uid| DB[:user_followers].insert(:follower_id => user_id, :user_id => uid) }
      SocialNetworkAnalyser.degree_centrality(:user_followers, :follower_id, user_id).should == 5
    end
    
    it "should compute indegree centrality properly" do
      user_id = DB[:users].insert
      @user_ids.each { |uid| DB[:user_followers].insert(:follower_id => uid, :user_id => user_id) }
      SocialNetworkAnalyser.degree_centrality(:user_followers, :user_id, user_id).should == 5
    end
  end

  describe "page rank" do
    it "should compute page rank properly" do
      DB[:user_followers].insert(:follower_id => @user_ids[0], :user_id => @user_ids[1])
      DB[:user_followers].insert(:follower_id => @user_ids[0], :user_id => @user_ids[2])
      DB[:user_followers].insert(:follower_id => @user_ids[1], :user_id => @user_ids[3])
      DB[:user_followers].insert(:follower_id => @user_ids[1], :user_id => @user_ids[4])
      DB[:user_followers].insert(:follower_id => @user_ids[2], :user_id => @user_ids[3])
      DB[:user_followers].insert(:follower_id => @user_ids[2], :user_id => @user_ids[4])
      DB[:user_followers].insert(:follower_id => @user_ids[3], :user_id => @user_ids[4])

      SocialNetworkAnalyser.page_rank(:user_followers, :follower_id, :user_id, @user_ids[4]).should == 0.613621875
    end
  end

  describe "betweenness centrality" do
    it "should compute betweenness centrality properly" do
      2.times { @user_ids << DB[:users].insert }
      DB[:user_followers].insert(:follower_id => @user_ids[0], :user_id => @user_ids[1])
      DB[:user_followers].insert(:follower_id => @user_ids[1], :user_id => @user_ids[2])
      DB[:user_followers].insert(:follower_id => @user_ids[2], :user_id => @user_ids[3])
      DB[:user_followers].insert(:follower_id => @user_ids[0], :user_id => @user_ids[4])
      DB[:user_followers].insert(:follower_id => @user_ids[1], :user_id => @user_ids[5])
      DB[:user_followers].insert(:follower_id => @user_ids[4], :user_id => @user_ids[5])
      DB[:user_followers].insert(:follower_id => @user_ids[5], :user_id => @user_ids[6])

      SocialNetworkAnalyser.betweenness_centrality(:users, :id, :user_followers, :follower_id, :user_id, @user_ids[1]).should == 3
      SocialNetworkAnalyser.betweenness_centrality(:users, :id, :user_followers, :follower_id, :user_id, @user_ids[4]).should == 1
    end
  end
end
