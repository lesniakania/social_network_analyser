require 'config/test'
require 'social_network_analyser'

describe SocialNetworkAnalyser do
  before(:each) do
    @user_ids = (1..7).map { DB[:users].insert }
  end

  describe "centrality" do
    it "should compute outdegree centrality properly" do
      user_id = DB[:users].insert
      @user_ids.each { |uid| DB[:user_followers].insert(:follower_id => user_id, :user_id => uid) }
      SocialNetworkAnalyser.degree_centrality(:user_followers, :follower_id, user_id).should == 7
    end
    
    it "should compute indegree centrality properly" do
      user_id = DB[:users].insert
      @user_ids.each { |uid| DB[:user_followers].insert(:follower_id => uid, :user_id => user_id) }
      SocialNetworkAnalyser.degree_centrality(:user_followers, :user_id, user_id).should == 7
    end
  end
end
