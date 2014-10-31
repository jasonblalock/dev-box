#!/bin/bash

rubyversion=2.1.4

getinfo()
{
  read -p "Enter your name for git: " gitname
  read -p "Enter your username for github : " gitusername
  read -p "Enter the ip address for your server (192.168.1.22): " staticip
  # read -p "Enter the netmask for your network: (looks like 255.255.255) " netmask
}

writeinterfacefile()
{
  cat << EOF >> /etc/network/interfaces

#Your static network configuration
auto eth1
iface eth1 inet static
address $staticip
netmask 255.255.255.0
EOF
}

confirmation()
{
  sudo -u $1 echo ""
  sudo -u $1 echo "So your settings are:"
  sudo -u $1 echo "Your git config name is: " $gitname
  sudo -u $1 echo "Your Github username is: " $gitusername
  sudo -u $1 echo "Your IP is:              " $staticip
  # sudo -u $1 echo "You subnet mask is " $netmask
  sudo -u $1 echo ""

  while true; do
    read -p "Are these informations correct? [y/N] " yn
    case $yn in
      [Yy]* ) writeinterfacefile; break;;
      [Nn]* ) getinfo ;;
      * ) sudo -u $1 echo "Please enter Y or n ";;
    esac
  done
}

clear
cd ~
getinfo $1
confirmation $1
aptitude -y install software-properties-common
add-apt-repository -y ppa:git-core/ppa
aptitude update
aptitude -y safe-upgrade
aptitude -y install build-essential vim ruby-dev git libsqlite3-dev openssh-server
vmware-config-tools.pl -d

sudo -u $1 git config --global user.name "$gitname"
sudo -u $1 git config --global user.email "$gitusername@users.noreply.github.com"
sudo -u $1 git config --global core.autocrlf input
sudo -u $1 git config --global branch.autosetuprebase always

sudo -u $1 wget -O chruby-0.3.8.tar.gz https://github.com/postmodern/chruby/archive/v0.3.8.tar.gz
sudo -u $1 tar -xzvf chruby-0.3.8.tar.gz
cd chruby-0.3.8/
make install
cd ~

if [ ! -e /etc/profile.d/chruby.sh ]; then
cat << EOF >> /etc/profile.d/chruby.sh
if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
  source /usr/local/share/chruby/chruby.sh
  source /usr/local/share/chruby/auto.sh
fi
EOF
fi

chmod u+x /etc/profile.d/chruby.sh
sudo -u $1 source /etc/profile.d/chruby.sh

sudo -u $1 wget -O ruby-install-0.5.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.5.0.tar.gz
sudo -u $1 tar -xzvf ruby-install-0.5.0.tar.gz
cd ruby-install-0.5.0/
make install
cd ~
sudo -u $1 ruby-install ruby $rubyversion
sudo -u $1 echo "gem: --no-document" > ~/.gemrc
sudo -u $1 echo "ruby-$rubyversion" > ~/.ruby-version
sudo -u $1 chruby ruby-$rubyversion

sudo -u $1 gem update --system
sudo -u $1 gem install bundler
sudo -u $1 gem install rake

chruby-exec -- gem install chef
sudo -u $1 gem install berkshelf
sudo -u $1 git clone git@github.com:jasonblalock/rails-dev-box.git
cd rails-dev-box
sudo -u $1 berks vendor kitchen/cookbooks
chruby-exec -- chef-solo -c solo.rb -j solo.json

read -p "Restart? [y/N] " yn
case $yn in
  [Yy]* ) reboot;;
  [Nn]* ) exit;;
esac
