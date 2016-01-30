set :application, ""
set :deploy_user, "deploy"

# setup repo details
set :scm, :git
set :repo_url, ""

# how many old releases do we want to keep
set :keep_releases, 5

# files we want symlinking to specific entries in shared.
set :linked_files, %w{config/database.yml config/secrets.yml}

# dirs we want symlinking to shared
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets}

# what specs should be run before deployment is allowed to
# continue, see lib/capistrano/tasks/run_tests.cap
set :tests, []

# Set number of cores bundler can use
set :bundle_jobs, 4

# this:
# http://www.capistranorb.com/documentation/getting-started/flow/
# is worth reading for a quick overview of what tasks are called
# and when for `cap stage deploy`

namespace :deploy do  
  # make sure we're deploying what we think we're deploying
  before :deploy, "deploy:check_revision"

  # only allow a deploy with passing tests to be deployed
  # before :deploy, "deploy:run_tests"
end
