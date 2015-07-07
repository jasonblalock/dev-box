dev-box
=============
# Automatic Install

## Initial config

    wget https://raw.githubusercontent.com/jasonblalock/dev-box/master/part1.sh --no-cache
    wget https://raw.githubusercontent.com/jasonblalock/dev-box/master/part2.sh --no-cache
    chmod u+x part1.sh part2.sh

## Run Part 1

    sudo ./part1.sh <username>

Reboot when script is finished.

## Run Part 2

    ./part2.sh

Done!

## Misc

Disable elasticsearch service on start

    sudo update-rc.d elasticsearch disable

Set timezone

    sudo dpkg-reconfigure tzdata

Multi-threaded bundler

    nproc   # returns number of threads
    bundle config --global jobs X   # replace 'X' with nproc result

vmware-tools kernel version error

    #!/bin/sh -x
    cd /usr/lib/vmware-tools/modules/source
    tar xf vmhgfs.tar
    grep -q d_u.d_alias vmhgfs-only/inode.c && echo "already patched" && exit 0
    sed -i -e s/d_alias/d_u.d_alias/ vmhgfs-only/inode.c
    cp -p vmhgfs.tar vmhgfs.tar.orig
    tar cf vmhgfs.tar vmhgfs-only

# Manual Install

## Initial config

    sudo aptitude install software-properties-common && sudo add-apt-repository ppa:git-core/ppa && sudo aptitude update && sudo aptitude safe-upgrade && sudo aptitude install build-essential vim ruby-dev git libsqlite3-dev openssh-server
    sudo vmware-config-tools.pl

### Git

    git config --global user.name "John Doe"
    git config --global user.email johndoe@example.com
    git config --global core.autocrlf input
    git config --global branch.autosetuprebase always

### Network

Open /etc/network/interfaces in editor

    sudo vim /etc/network/interfaces

Add network configuration

    auto eth1
    iface eth1 inet static
    address 192.168.33.10
    netmask 255.255.255.0

## chruby

### Install

    wget -O chruby-0.3.8.tar.gz https://github.com/postmodern/chruby/archive/v0.3.8.tar.gz
    tar -xzvf chruby-0.3.8.tar.gz
    cd chruby-0.3.8/
    sudo make install

### Configuration

#### System Wide

If you wish to enable chruby system-wide, add the following to
`/etc/profile.d/chruby.sh`:

``` bash
if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
  source /usr/local/share/chruby/chruby.sh
  source /usr/local/share/chruby/auto.sh
fi
```

This will prevent chruby from accidentally being loaded by `/bin/sh`, which
is not always the same as `/bin/bash`.

## ruby-install

### Install

    wget -O ruby-install-0.5.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.5.0.tar.gz
    tar -xzvf ruby-install-0.5.0.tar.gz
    cd ruby-install-0.5.0/
    sudo make install

## Ruby

    ruby-install ruby 2.1.4
    echo "gem: --no-document" > ~/.gemrc
    echo "ruby-2.1.4" > ~/.ruby-version

Restart

### Additional steps

    gem update --system

### Bundler

    gem install bundler
    gem install rake

## Chef

### Install

    sudo chruby-exec -- gem install chef

### Berkshelf

    gem install berkshelf

## Kitchen

### Setup

    git clone git@github.com:jasonblalock/rails-dev-box.git
    cd rails-dev-box
    berks vendor kitchen/cookbooks

### Run

    sudo chruby-exec -- chef-solo -c solo.rb -j solo.json




