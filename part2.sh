#!/bin/bash

rubyversion=2.1.5

getinfo()
{
  read -p "Enter your name for git: " gitname
  read -p "Enter your username for github : " gitusername
}

confirmation()
{
  echo ""
  echo "So your settings are:"
  echo "Your git config name is: " $gitname
  echo "Your Github username is: " $gitusername
  echo ""

  while true; do
    read -p "Are these informations correct? [y/N] " yn
    case $yn in
      [Yy]* ) break;;
      [Nn]* ) getinfo ;;
      * ) echo "Please enter Y or n ";;
    esac
  done
}

cd ~
getinfo
confirmation

git config --global user.name $gitname
git config --global user.email "${gitusername}@users.noreply.github.com"
git config --global core.autocrlf input
git config --global branch.autosetuprebase always

echo "gem: --no-document" > ~/.gemrc
echo "ruby-${rubyversion}" > ~/.ruby-version

cd ~
chruby-exec "ruby-${rubyversion}" -- gem update --system
chruby-exec "ruby-${rubyversion}" -- gem install bundler
chruby-exec "ruby-${rubyversion}" -- gem install rake
chruby-exec "ruby-${rubyversion}" -- gem install berkshelf

sudo chruby-exec "ruby-${rubyversion}" -- gem install chef
wget https://github.com/jasonblalock/rails-dev-box/archive/master.tar.gz
tar -xzvf master.tar.gz
cd rails-dev-box-master
sudo chruby-exec "ruby-${rubyversion}" -- berks vendor kitchen/cookbooks
sudo chruby-exec "ruby-${rubyversion}" -- chef-solo -c solo.rb -j solo.json

read -p "Restart? [y/N] " yn
case $yn in
  [Yy]* ) sudo reboot;;
  [Nn]* ) exit;;
esac
