# == Class: certificate
# This is the init.pp file. Here, we install the necessary tools for managing SSL certificates.
#
# === Parameters
# None.
#
# === Examples
# include certificate
#
# === Authors
# Mattias Geniar <m@ttias.be>
#
class certificate {
  # Install the crypto-utils package, needed for the certwatch utility
  package { 'crypto-utils':
    ensure  => present,
  }

  # Remove the default daily cron for reporting on certificates. We manage all certificates
  # via puppet, so don't need a tool to start guessing where the SSL certificates are on this system.
  file { '/etc/cron.daily/certwatch':
    ensure  => absent,
  }
}
