
set :stage, :staging
set :branch, "staging"
set :rails_env, :staging    #set the rails environment
set :bundle_flags, "--deployment"
# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

server 'example.com', user: 'deploy', roles: %w{web app db}
