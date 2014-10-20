rails-dev-box
=============
# Initial config

    sudo aptitude update && sudo aptitude safe-upgrade && sudo aptitude install build-essential vim software-properties-common ruby-dev
    sudo add-apt-repository ppa:git-core/ppa
    sudo aptitude update && sudo aptitude install git

# chruby

## Install

    wget -O chruby-0.3.8.tar.gz https://github.com/postmodern/chruby/archive/v0.3.8.tar.gz
    tar -xzvf chruby-0.3.8.tar.gz
    cd chruby-0.3.8/
    sudo make install

## Configuration

### System Wide

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

# ruby-install

## Install

    wget -O ruby-install-0.5.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.5.0.tar.gz
    tar -xzvf ruby-install-0.5.0.tar.gz
    cd ruby-install-0.5.0/
    sudo make install

# Ruby

    ruby-install ruby 2.1.3
    echo "gem: --no-document" > ~/.gemrc
    echo "ruby-2.1.3" > ~/.ruby-version

Restart

## Additional steps

    gem update --system

## Bundler

    gem install bundler
    gem install rake

# Chef

## Install

    sudo chruby-exec -- gem install chef

## Berkshelf

    gem install berkshelf

