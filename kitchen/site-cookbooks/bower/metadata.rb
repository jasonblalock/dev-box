name "bower"
maintainer "Jason Blalock"
maintainer_email "jason.blalock@excella.com"
description 'Installs bower'
version '0.1.0'

supports "ubuntu", "~> 14.04.0"

depends 'nodejs'

recipe "bower::default", "Installs bower package"
