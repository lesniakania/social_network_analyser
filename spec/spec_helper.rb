require 'config/environment/test'

Spec::Runner.configure do |config|
  config.before(:each) do
    drop_tables
    create_tables
  end
end
