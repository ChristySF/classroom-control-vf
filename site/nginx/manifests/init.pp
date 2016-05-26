class nginx { 
   yumrepo { 'base': 
     ensure              => 'present', 
     descr               => 'CentOS-$releasever - Base', 
     enabled             => '1', 
     gpgcheck            => '1', 
     gpgkey              => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7', 
     mirrorlist          => 'http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os&infra=$infra', 
     priority            => '99', 
       skip_if_unavailable => '1', 
       before              => [ Package['nginx'], Package['openssl-libs'] ], 
   } 
    
   yumrepo { 'updates': 
     ensure              => 'present', 
     descr               => 'CentOS-$releasever - Updates', 
     enabled             => '1', 
     gpgcheck            => '1', 
     gpgkey              => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7', 
     mirrorlist          => 'http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates&infra=$infra', 
     priority            => '99', 
     skip_if_unavailable => '1', 
     before              => [ Package['nginx'], Package['openssl-libs'] ], 
   } 
    
   yumrepo { 'extras': 
     ensure              => 'present', 
     descr               => 'CentOS-$releasever - Extras', 
     enabled             => '1', 
     gpgcheck            => '1', 
     gpgkey              => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7', 
     mirrorlist          => 'http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras&infra=$infra', 
     priority            => '99', 
     skip_if_unavailable => '1', 
     before              => [ Package['nginx'], Package['openssl-libs'] ], 
   } 
    
   yumrepo { 'centosplus': 
     ensure     => 'present', 
     descr      => 'CentOS-$releasever - Plus', 
     enabled    => '1', 
     gpgcheck   => '1', 
     gpgkey     => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7', 
     mirrorlist => 'http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus&infra=$infra', 
     before     => [ Package['nginx'], Package['openssl-libs'] ], 
   } 
 
   package { [ 'openssl', 'openssl-libs' ] : 
     ensure => '1.0.1e-51.el7_2.5', 
     before => Package['nginx'], 
   } 
 
   file { 'nginx rpm' : 
     ensure   => file, 
     path     => '/opt/nginx-1.6.2-1.el7.centos.ngx.x86_64.rpm', 
     source   => 'puppet:///modules/nginx/nginx-1.6.2-1.el7.centos.ngx.x86_64.rpm', 
   } 
 
 #  package { 'nginx' : 
 #    ensure   => '1.6.2-1.el7.centos.ngx', 
 #    source   => '/opt/nginx-1.6.2-1.el7.centos.ngx.x86_64.rpm', 
 #    provider => rpm, 
 #    require  => File['nginx rpm'], 
 #  } 
   
   case $::osfamily {
     'redhat','debian' : {
       $package = 'nginx'
       $owner   = 'root'
       $group   = 'root'
       $docroot = '/var/www/'
       $confdir = '/etc/nginx'
       $logdir  = '/var/log/nginx'
     }
     'windows' : {
       $package = 'nginx-service'
       $owner   = 'Administrator'
       $group   = 'Administrator'
       $docroot = 'C:/ProgramData/nginx/html'
       $confdir = 'C:/ProgramData/nginx'
       $logdir  = 'C:/ProgramData/nginx/logs'
      }
      default : {
        fail("Module $(modules_name) is not supported on ${::osfamily}")
      }
   }
   
   $user = $::osfamily ? {
     'redhat'  => 'nginx',
     'debian'  => 'www-data',
     'windows' => 'nobody',
   }
   
   File {
     owner   => 'root',
     group   => 'root',
     mode    => '0644',
   }
   
   package { $package: 
     ensure => present,
   }
     
   file { [ $docroot, $confdir ]:  
     ensure  => directory,  
   }  
   
   file { "$(confdir)/conf.d" :
     ensure => directory,
   }
   
   file { "$(docroot)/index.html" :  
     ensure  => file,  
     source  => 'puppet:///modules/nginx/index.html',  
   }  
   
   file { "$(confdir)/nginx.conf" :  
     ensure  => file,  
     content => template('nginx/nginx.conf.erb'),
     notify  => Service['nginx'],  
   }  
   
   file { "$(confdir)/conf.d/default conf" :  
     ensure  => file,  
     content => template('nginx/default.conf.erb'),
     notify  => Service['nginx'],  
   }  
   
   service { 'nginx' :  
     ensure => running,  
     enable => true,  
   }  
}
