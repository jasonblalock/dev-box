#!/bin/bash

rubyversion=2.1.4

getinfo()
{
  sudo -u ${USERNAME} read -p "Enter your name for git:  (looks like 192.168.1.22)" gitname
  sudo -u ${USERNAME} read -p "Enter your email for git: (looks like username@users.noreply.github.com)" gitemail
  sudo -u ${USERNAME} read -p "Enter the ip address for your server:  (looks like 192.168.1.22)" staticip
  sudo -u ${USERNAME} read -p "Enter the netmask for your network:    (looks like 255.255.255)" netmask
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
  sudo -u ${USERNAME} echo""
  sudo -u ${USERNAME} echo"So your settings are"
  sudo -u ${USERNAME} echo "Git name is                  " echo -n $gitname
  sudo -u ${USERNAME} echo "Git email is                 " echo -n $gitemail
  sudo -u ${USERNAME} echo "Your decided Server IP is    " echo -n $istaticp
  sudo -u ${USERNAME} echo "The Mask fpr the Network is  " echo -n $netmask
  sudo -u ${USERNAME} echo""
  sudo -u ${USERNAME} echo "Are these informations correct? (Y/n)"

while true; do
  sudo -u ${USERNAME} read -p "Are these informations correct? [y/N]" yn?
  case $yn in
    [Yy]* ) writeinterfacefile ;;
    [Nn]* ) getinfo ;;
    * ) sudo -u ${USERNAME} echo "Pleas enter Y or n";;
  esac
  done
}

clear
sudo -u ${USERNAME} cd
getinfo
confirmation
aptitude install software-properties-common
add-apt-repository ppa:git-core/ppa
aptitude update
aptitude safe-upgrade
aptitude install build-essential vim ruby-dev git libsqlite3-dev openssh-server
sudo vmware-config-tools.pl -d

sudo -u ${USERNAME} git config --global user.name "$gitname"
sudo -u ${USERNAME} git config --global user.email $gitemail
sudo -u ${USERNAME} git config --global core.autocrlf input
sudo -u ${USERNAME} git config --global branch.autosetuprebase always

sudo -u ${USERNAME} wget -O chruby-0.3.8.tar.gz https://github.com/postmodern/chruby/archive/v0.3.8.tar.gz
sudo -u ${USERNAME} tar -xzvf chruby-0.3.8.tar.g
make chruby-0.3.8/install

if [ ! -e /etc/profile.d/chruby.sh ]; then
cat << EOF >> /etc/profile.d/chruby.sh
if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
  source /usr/local/share/chruby/chruby.sh
  source /usr/local/share/chruby/auto.sh
fi
EOF
fi

sudo -u ${USERNAME} wget -O ruby-install-0.5.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.5.0.tar.gz
sudo -u ${USERNAME} tar -xzvf ruby-install-0.5.0.tar.gz
make ruby-install-0.5.0/install
sudo -u ${USERNAME} ruby-install ruby $rubyversion
sudo -u ${USERNAME} echo "gem: --no-document" > ~/.gemrc
sudo -u ${USERNAME} echo "ruby-$rubyversion" > ~/.ruby-version
sudo -u ${USERNAME} source /usr/local/share/chruby/chruby.sh
sudo -u ${USERNAME} source /usr/local/share/chruby/auto.sh
sudo -u ${USERNAME} chruby ruby-$rubyversion

sudo -u ${USERNAME} gem update --system
sudo -u ${USERNAME} gem install bundler
sudo -u ${USERNAME} gem install rake

sudo chruby-exec -- gem install chef
sudo -u ${USERNAME} gem install berkshelf
sudo -u ${USERNAME} git clone git@github.com:jasonblalock/rails-dev-box.git
sudo -u ${USERNAME} cd rails-dev-box
sudo -u ${USERNAME} berks vendor kitchen/cookbooks
sudo chruby-exec -- chef-solo -c solo.rb -j solo.json
