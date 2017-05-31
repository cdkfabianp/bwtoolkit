

# How to Prepare System:

## Install RVM
+ gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
+ \curl -sSL https://get.rvm.io | bash -s stable 
+ source ~/.profile

## Install Ruby 2.1.1
+ rvm install 2.1.1

## Download Bundler
+ gem install bundler

## Get bwtoolkit
+ git clone <toolkit_repo>

## Install Ruby Dependencies
+ cd bwtoolkit
+ bundle install

## Run bwtoolkit
+ ./toolkit