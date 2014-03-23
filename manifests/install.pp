# Definition: certificate::install
#
# Parameters
# - Mandatory
#   keyfile           => File location to the Certificate Key in full format. Ie: puppet:///modules/client/certificate.key
#   certificatefile   => File location to the Public certificate in full format. Ie: puppet:///modules/client/certificate.crt
#   owner             => Ownership of the files should be set to this user
#   group             => Group ownership of the files
#   installpath       => The directory where to install the certificate files
#
# - Optional
#   cabundle          => If necessary, the additional ca-bundle in full format. Ie: puppet:///modules/client/certificate.ca-bundle
#   alert_expiration  => true/false, to set up alerts when this certificate is about to expire
#   alert_timeframe   => How many days before the expiration should we send out notifications?
#   alert_email       => Where should we send the alerts for the expiration to?
#
# Example
#  certificate::install { 'www.domain.tld':
#    keyfile           => 'puppet:///files/client/www.domain.tld/server.key',
#    certificatefile   => 'puppet:///files/client/www.domain.tld/server.crt',
#    owner             => 'nginx',
#    group             => 'nginx',
#    installpath       => '/etc/nginx/ssl/www.domain.tld',
#  }
#
# Authors
#   Mattias Geniar <m@ttias.be>
#
define certificate::install (
  $keyfile,
  $certificatefile,
  $owner,
  $group,
  $installpath,
  $cabundle           = undef,
  $alert_expiration   = true,
  $alert_timeframe    = 30,
  $alert_email        = 'm@ttias.be',
) {
  include stdlib
  include certificate

  # Basic validation
  if ($keyfile == undef) {
    fail('The keyfile parameter in the certificate::install is not set')
  }
  validate_re($keyfile, '^puppet://', 'The keyfile parameter needs to start with puppet://')

  if ($certificatefile == undef) {
    fail('The certificatefile parameter in the certificate::install is not set')
  }
  validate_re($certificatefile, '^puppet://', 'The certificatefile parameter needs to start with puppet://')

  if ($owner == undef) {
    fail('The owner parameter in the certificate::install is not set')
  }

  if ($group == undef) {
    fail('The group parameter in the certificate::install is not set')
  }

  if ($installpath == undef) {
    fail('The installpath parameter in the certificate::install is not set')
  }

  # Make sure the installpath is valid
  validate_absolute_path($installpath)

  # Some assembled parameters
  $certificate_location = "${installpath}/certificate.crt"
  $privatekey_location  = "${installpath}/certificate.key"
  $cabundle_location    = "${installpath}/certificate.ca-bundle"

  # Create the directory where to store the certificate
  file { $installpath:
    ensure  => directory,
    owner   => $owner,
    group   => $group,
    mode    => '0550',
  }

  # Install the certificate (public part)
  file { $certificate_location:
    ensure  => file,
    owner   => $owner,
    group   => $group,
    mode    => '0440',
    source  => $certificatefile,
    require => File [ $installpath ],
  }

  # Install the private key
  file { $privatekey_location:
    ensure  => file,
    owner   => $owner,
    group   => $group,
    mode    => '0440',
    source  => $keyfile,
    require => File [ $installpath ],
  }

  # Install the ca-bundle, if set
  if ($cabundle != undef) {
    file { $cabundle_location:
      ensure  => file,
      owner   => $owner,
      group   => $group,
      mode    => '0440',
      source  => $cabundle,
      require => File [ $installpath ],
    }
  }

  # If we want alerting, create a weekly crontask for reporting on the validity of the certificate
  if ($alert_expiration == true) {
    file { "/etc/cron.weekly/certwatch-${name}":
      ensure  => file,
      mode    => '0750',
      owner   => 'root',
      group   => 'root',
      content => template('certificate/certwatch.sh.erb'),
    }
  }
}