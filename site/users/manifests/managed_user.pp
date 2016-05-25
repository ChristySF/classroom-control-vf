define users::managed_user (
  $group = $title,
)
{
  user {$title:
    ensure => present,
    gid    => $group,
  }
  
  file { "/home/$(title)":
    ensure => directory,
    owner  => $title,
    group  => $group
  }
  
  group {$title:
    ensure => present,
  }
}
