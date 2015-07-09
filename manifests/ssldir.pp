class cutover::ssldir ( $ssldir ) {
  cutover::private_warning { 'cutover::ssldir': }
  validate_string($ssldir)
  validate_absolute_path($ssldir)

  if ! defined(Service['pe-puppet']) {
    service { 'pe-puppet': }
  }

  exec { 'remove_ssldir':
    command     => "/bin/rm -rf ${ssldir}",
    refreshonly => true,
    onlyif      => "/usr/bin/test ${ssldir}",
    notify      => Service['pe-puppet']
  }

  exec { 'remove_crl':
    command     => "/bin/rm -f ${ssldir}/crl.pem",
    refreshonly => true,
    onlyif      => "/bin/bash -c '/opt/puppet/bin/openssl crl -in /etc/puppetlabs/puppet/ssl/crl.pem -text -noout |/bin/grep pupsnq01'", #REMEMBER /bin/bash is wrong on RHEL 7
    require     => Exec['remove_ssldir'],
    notify      => Service['pe-puppet'],
  }

    ### USE WITH STAGES ###
}
