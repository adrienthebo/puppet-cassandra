# Install cassandra
#
# == Caveats: This is debian centric. deal with it.
class cassandra($release = '11x') {

  apt::source { 'apache-cassandra':
    key        => '2B5C1B00',
    key_server => 'pgp.mit.edu',
    location   => 'http://www.apache.org/dist/cassandra/debian',
    release    => $release,
    repos      => 'main',
  }

  package { 'cassandra':
    ensure  => present,
    require => Apt::Source['apache-cassandra'],
  }
}
