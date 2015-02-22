#!/bin/bash

source config.sh

getinfo()
{
  read -p "Enter your name for git: " gitname
  read -p "Enter your username for github : " gitusername
  read -p ""

  PS3='Please select your Chef provision config: '
  options=("Base development config" "Full config" "Quit")
  select chefopt in "${options[@]}"
  do
    case $chefopt in
      "Base development config")
          chef="dev.json"
          ;;
      "Full config")
          chef="full.json"
          ;;
      "Quit")
          break
          ;;
      *) echo invalid option;;
    esac
  done
}

confirmation()
{
  echo ""
  echo "So your settings are:"
  echo "Your git config name is: " $gitname
  echo "Your Github username is: " $gitusername
  echo "Your Chef provsion config is: " $chefopt
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
wget https://github.com/jasonblalock/rails-dev-box/archive/master.tar.gz --no-cache
tar -xzvf master.tar.gz
cd rails-dev-box-master
chruby-exec "ruby-${rubyversion}" -- berks vendor kitchen/cookbooks
sudo chruby-exec "ruby-${rubyversion}" -- chef-solo -c solo.rb -j $chef

read -p "Restart? [y/N] " yn
case $yn in
  [Yy]* ) sudo reboot;;
  [Nn]* ) exit;;
esac
