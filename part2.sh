cd ~
sudo -u $1 gem update --system
sudo -u $1 gem install bundler
sudo -u $1 gem install rake

chruby-exec -- gem install chef
sudo -u $1 gem install berkshelf
sudo -u $1 wget https://github.com/jasonblalock/rails-dev-box/archive/master.tar.gz
sudo -u $1 tar -xzvf master.tar.gz
cd rails-dev-box-master
sudo -u $1 berks vendor kitchen/cookbooks
chruby-exec -- chef-solo -c solo.rb -j solo.json

read -p "Restart? [y/N] " yn
case $yn in
  [Yy]* ) reboot;;
  [Nn]* ) exit;;
esac
