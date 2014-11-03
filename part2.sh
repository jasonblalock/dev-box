#!/bin/bash

cd ~
gem update --system
gem install bundler
gem install rake
gem install berkshelf

sudo chruby-exec -- gem install chef
gem install berkshelf
wget https://github.com/jasonblalock/rails-dev-box/archive/master.tar.gz
tar -xzvf master.tar.gz
cd rails-dev-box-master
berks vendor kitchen/cookbooks
sudo chruby-exec -- chef-solo -c solo.rb -j solo.json

read -p "Restart? [y/N] " yn
case $yn in
  [Yy]* ) sudo reboot;;
  [Nn]* ) exit;;
esac
