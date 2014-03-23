puppet-certificate
==================

Manage SSL certificates through a Puppet defined type. You pass your location to the certificate and private key and this type does the rest.

It will set up auto-expiration notifications, so you always know when your SSL certificates will expire and you can act on time.

This module also enforces a strict filename convention and permission scheme for all certificates.

Usage
-----

```
certificate::install { 'www.domain.tld':
  keyfile           => 'puppet:///files/client/www.domain.tld/server.key',
  certificatefile   => 'puppet:///files/client/www.domain.tld/server.crt',
  owner             => 'nginx',
  group             => 'nginx',
  installpath       => '/etc/nginx/ssl/www.domain.tld',
}
```

Result:
```
~# ls -alh /etc/nginx/ssl/www.domain.tld
-r--r----- 1 nginx nginx 4.7K Mar 23 10:05 certificate.crt
-r--r----- 1 nginx nginx 1.7K Mar 23 10:05 certificate.key
```

This ensures a more standardized way of handling SSL certificates.

TODO
----

This module can use some rspec tests and perhaps a better README file.

CONTRIBUTION
------------

You can do whatever you like with this module. If you have some cool additions, please send a pull request or contact me.