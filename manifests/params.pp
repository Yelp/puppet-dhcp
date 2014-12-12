# Class: dhcp::params
#
# Do NOT include this class - it won't do anything.
# Set variables for names and paths
#
class dhcp::params {

  case $::operatingsystem {

    /Debian|Ubuntu/: {
      $config_dir = $::lsbdistcodename? {
        /lenny/  => '/etc/dhcp3',
        /squeeze|wheezy|lucid|precise/ => '/etc/dhcp',
      }

      $srv_dhcpd = $::lsbdistcodename? {
        /lenny/            => 'dhcp3-server',
        /squeeze|wheezy|lucid|precise/ => 'isc-dhcp-server',
      }

      $service_pattern = $::lsbdistcodename? {
        /lenny/           => '/usr/sbin/dhcpd3',
        /squeeze|wheezy|lucid|precise/ => '/usr/sbin/dhcpd',
      }

      $server_template = "${module_name}/dhcpd.conf.debian.erb"
    }

    default: {
      fail "Unsupported OS ${::operatingsystem}/${::lsbdistcodename}"
    }

  }
}
