package {'memcached':
  ensure => present,
}
  
file {'/etc/sysconfig/memcached':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  require => Package['memcache'],
}

service {'memcached':
  ensure    => running,
  enable    => true,
  subscribe => File['/etc/sysconfig/memcached'],
}
