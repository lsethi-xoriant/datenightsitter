# Load the Rails application.
require File.expand_path('../application', __FILE__)

#custom application configurations
APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]


# Initialize the Rails application.
Rails.application.initialize!
