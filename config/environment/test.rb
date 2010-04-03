require 'config/init'
require 'ruby-debug'

DB = Sequel.connect(
  :adapter => DataBase::CONFIG['test']['adapter'],
  :host => DataBase::CONFIG['test']['host'],
  :database => DataBase::CONFIG['test']['database'],
  :user => DataBase::CONFIG['test']['user'],
  :password => DataBase::CONFIG['test']['password']
)

def create_tables
  DB.create_table :users do
    primary_key :id
  end

  DB.create_table :twitts do
    primary_key :id, :varchar, :auto_increment => false
    foreign_key :parent_id, :twitts, :type => :varchar
  end

  DB.create_table :user_followers do
    primary_key :id
    foreign_key :user_id, :users
    foreign_key :follower_id, :users
  end
end

def drop_tables
  DB.drop_table :user_followers if DB.tables.include?(:user_followers)
  DB.drop_table :twitts if DB.tables.include?(:twitts)
  DB.drop_table :users if DB.tables.include?(:users)
end

def clear_tables
  UserFollower.delete
  Twitt.delete
  User.delete
end
