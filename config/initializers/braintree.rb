require "braintree"
#configuration of environment
Braintree::Configuration.environment = APP_CONFIG["braintree"]["environment"]
Braintree::Configuration.merchant_id = APP_CONFIG["braintree"]["merchant_id"]
Braintree::Configuration.public_key = Rails.application.secrets.braintree_public_key
Braintree::Configuration.private_key = Rails.application.secrets.braintree_private_key
