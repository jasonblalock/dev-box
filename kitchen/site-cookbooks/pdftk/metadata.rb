name "pdftk"
maintainer "Excella Consulting"
maintainer_email "jason.blalock@excella.com"
description 'Installs pdftk package'
version '0.1.0'

supports "ubuntu", "~> 14.04.0"

depends 'apt'

recipe "pdftk::default", "Installs pdftk package"
