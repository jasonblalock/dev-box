#!/bin/bash

if [ ! -f config.sh ]; then
    echo "No config file. Downloading..."
    wget https://raw.githubusercontent.com/jasonblalock/dev-box/master/config.sh --no-cache
fi

source config.sh

getinfo()
{
  read -p "Enter your name for git: " gitname
  read -p "Enter your username for github : " gitusername

  PS3='Please select your Chef provision config: '
  options=("Base development config" "Full config" "Quit")
  select chefopt in "${options[@]}"
  do
    case $chefopt in
      "Base development config")
          chef="dev.json"
          break
          ;;
      "Full config")
          chef="full.json"
          break
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
  echo "Your Chef provision config is: " $chefopt
  echo ""

  while true; do
    read -p "Is this informations correct? [y/N] " yn
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

git config --global user.name "${gitname}"
git config --global user.email "${gitusername}@users.noreply.github.com"
git config --global core.autocrlf input
git config --global branch.autosetuprebase always
git config --global pull.rebase true

echo "gem: --no-document" > ~/.gemrc
echo "ruby-${rubyversion}" > ~/.ruby-version

cd ~
NPROC=$(nproc)
chruby-exec "ruby-${rubyversion}" -- gem update --system
chruby-exec "ruby-${rubyversion}" -- gem install bundler
chruby-exec "ruby-${rubyversion}" -- gem install rake
chruby-exec "ruby-${rubyversion}" -- gem install berkshelf
chruby-exec "ruby-${rubyversion}" -- bundle config --global jobs $NPROC

sudo chruby-exec "ruby-${rubyversion}" -- gem install chef
wget https://github.com/jasonblalock/dev-box/archive/master.tar.gz --no-cache
tar -xzvf master.tar.gz
cd dev-box-master
chruby-exec "ruby-${rubyversion}" -- berks vendor kitchen/cookbooks
sudo chruby-exec "ruby-${rubyversion}" -- chef-solo -c solo.rb -j $chef

read -p "Restart? [y/N] " yn
case $yn in
  [Yy]* ) sudo reboot;;
  [Nn]* ) exit;;
esac
