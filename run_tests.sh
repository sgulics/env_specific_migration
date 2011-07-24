#!/bin/sh
# set -e

if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  source "$HOME/.rvm/scripts/rvm"
elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then
  source "/usr/local/rvm/scripts/rvm"
else
  printf "ERROR: An RVM installation was not found.\n"
fi

function run {
  gem list --local bundler | grep bundler || gem install bundler --no-ri --no-rdoc

  echo 'Running bundle exec rspec spec against the latest released version of rails'
  bundle update rails
  bundle exec rspec spec

  echo 'Running bundle exec rspec spec against Rails 3.1.0.rc4'
  export RAILS_VERSION='2.3.11' 
  bundle update rails 
  bundle exec rspec spec

  echo 'Running bundle exec rspec spec against Rails 3.1.0.rc4'
  export RAILS_VERSION='3.1.0.rc4' 
  bundle update rails 
  bundle exec rspec spec


}

rvm use ruby-1.9.2@env_specific_migration --create
run

echo 'Success!'

