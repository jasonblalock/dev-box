#!/bin/bash

rubyversion=2.1.4

getinfo()
{
  "Enter your name for git:  (looks like 192.168.1.22)" gitname
  "Enter your email for git: (looks like username@users.noreply.github.com)" gitemail
  "Enter the ip address for your server:  (looks like 192.168.1.22)" staticip
  "Enter the netmask for your network:    (looks like 255.255.255)" netmask
}

writeinterfacefile()
{
  cat << EOF >> /etc/network/interfaces

#Your static network configuration
iface eth0 inet static
address echo $staticip
netmask echo $netmask
EOF
}

confirmation()
{
  sudo -u $1 echo""
  sudo -u $1 echo"So your settings are"
  sudo -u $1 echo "Git name is                  " echo -n $gitname
  sudo -u $1 echo "Git email is                 " echo -n $gitemail
  sudo -u $1 echo "Your decided Server IP is    " echo -n $istaticp
  sudo -u $1 echo "The Mask fpr the Network is  " echo -n $netmask
  sudo -u $1 echo""
  sudo -u $1 echo "Are these informations correct? (Y/n)"

while true; do
  read -p "Are these informations correct? [y/N]" yn?
  case $yn in
    [Yy]* ) writeinterfacefile ;;
    [Nn]* ) getinfo ;;
    * ) sudo -u $1 echo "Pleas enter Y or n";;
  esac
  done
}

clear
sudo -u $1 cd
getinfo
confirmation
aptitude install software-properties-common
add-apt-repository ppa:git-core/ppa
aptitude update
aptitude safe-upgrade
aptitude install build-essential vim ruby-dev git libsqlite3-dev openssh-server
sudo vmware-config-tools.pl -d

sudo -u $1 git config --global user.name "$gitname"
sudo -u $1 git config --global user.email $gitemail
sudo -u $1 git config --global core.autocrlf input
sudo -u $1 git config --global branch.autosetuprebase always

sudo -u $1 wget -O chruby-0.3.8.tar.gz https://github.com/postmodern/chruby/archive/v0.3.8.tar.gz
sudo -u $1 tar -xzvf chruby-0.3.8.tar.g
make chruby-0.3.8/install

if [ ! -e /etc/profile.d/chruby.sh ]; then
cat << EOF >> /etc/profile.d/chruby.sh
if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
  source /usr/local/share/chruby/chruby.sh
  source /usr/local/share/chruby/auto.sh
fi
EOF
fi

sudo -u $1 wget -O ruby-install-0.5.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.5.0.tar.gz
sudo -u $1 tar -xzvf ruby-install-0.5.0.tar.gz
make ruby-install-0.5.0/install
sudo -u $1 ruby-install ruby $rubyversion
sudo -u $1 echo "gem: --no-document" > ~/.gemrc
sudo -u $1 echo "ruby-$rubyversion" > ~/.ruby-version
sudo -u $1 source /usr/local/share/chruby/chruby.sh
sudo -u $1 source /usr/local/share/chruby/auto.sh
sudo -u $1 chruby ruby-$rubyversion

sudo -u $1 gem update --system
sudo -u $1 gem install bundler
sudo -u $1 gem install rake

sudo chruby-exec -- gem install chef
sudo -u $1 gem install berkshelf
sudo -u $1 git clone git@github.com:jasonblalock/rails-dev-box.git
sudo -u $1 cd rails-dev-box
sudo -u $1 berks vendor kitchen/cookbooks
sudo chruby-exec -- chef-solo -c solo.rb -j solo.json
