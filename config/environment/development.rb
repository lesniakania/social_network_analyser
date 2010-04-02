require 'config/init'

DB = Sequel.connect(
  :adapter => DataBase::CONFIG['development']['adapter'],
  :host => DataBase::CONFIG['development']['host'],
  :database => DataBase::CONFIG['development']['database'],
  :user => DataBase::CONFIG['development']['user'],
  :password => DataBase::CONFIG['development']['password']
)
