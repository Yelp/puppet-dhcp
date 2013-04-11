require 'spec_helper'

describe 'dhcp' do
  context 'When on an unsupported OS' do
    let (:facts) { {
      :operatingsystem => 'RedHat',
      :osfamily        => 'Redhat',
      :lsbdistcodename => 'Santiago'
    } }

    it 'should fail' do
      expect {
        should contain_package('dhcp-server')
      }.to raise_error(Puppet::Error, /Unsupported OS RedHat\/Santiago/)
    end
  end

  context 'When on Debian lenny' do
    let (:facts) { {
      :operatingsystem => 'Debian',
      :osfamily        => 'Debian',
      :lsbdistcodename => 'lenny'
    } }

    # Package
    it { should contain_package('dhcp-server').with(
      :name => 'dhcp3-server'
    ) }

    # Config
    it { should contain_concat('/etc/dhcp3/dhcpd.conf').with(
      :owner => 'root',
      :group => 'root',
      :mode  => '0644'
    ) }

    it { should contain_concat__fragment('00.dhcp.server.base').with(
      :ensure  => 'present',
      :target  => '/etc/dhcp3/dhcpd.conf',
      :content => /log-facility/
      ).with_content(/ddns-update-style none;/).with_content(/#authoritative/)
    }

    # Service
    it { should contain_service('dhcpd').with(
      :ensure  => 'running',
      :name    => 'dhcp3-server',
      :enable  => true,
      :pattern => '/usr/sbin/dhcpd3'
    ) }
  end

  context 'When on Debian squeeze' do
    let (:facts) { {
      :operatingsystem => 'Debian',
      :osfamily        => 'Debian',
      :lsbdistcodename => 'squeeze'
    } }

    # Package
    it { should contain_package('dhcp-server').with(
      :name => 'isc-dhcp-server'
    ) }

    # Config
    it { should contain_concat('/etc/dhcp/dhcpd.conf').with(
      :owner => 'root',
      :group => 'root',
      :mode  => '0644'
    ) }

    it { should contain_concat__fragment('00.dhcp.server.base').with(
        :ensure  => 'present',
        :target  => '/etc/dhcp/dhcpd.conf',
        :content => /log-facility/
      ).with_content(/ddns-update-style none;/).with_content(/#authoritative/)
    }

    # Service
    it { should contain_service('dhcpd').with(
      :ensure  => 'running',
      :name    => 'isc-dhcp-server',
      :enable  => true,
      :pattern => '/usr/sbin/dhcpd'
    ) }
  end

  context 'When passing ddns_update' do
    let (:facts) { {
      :operatingsystem => 'Debian',
      :osfamily        => 'Debian',
      :lsbdistcodename => 'squeeze'
    } }
    let (:params) { {
      :server_ddns_update => 'foo'
    } }

    it { should contain_concat__fragment('00.dhcp.server.base').with(
        :ensure  => 'present',
        :target  => '/etc/dhcp/dhcpd.conf',
        :content => /log-facility/
      ).with_content(/ddns-update-style foo;/).with_content(/#authoritative/)
    }
  end

  context 'When passing authoritative' do
    let (:facts) { {
      :operatingsystem => 'Debian',
      :osfamily        => 'Debian',
      :lsbdistcodename => 'squeeze'
    } }
    let (:params) { {
      :server_authoritative => true
    } }

    it { should contain_concat__fragment('00.dhcp.server.base').with(
        :ensure  => 'present',
        :target  => '/etc/dhcp/dhcpd.conf',
        :content => /log-facility/
      ).with_content(/ddns-update-style none;/).with_content(/[^#]authoritative/)
    }
  end

  context 'When passing opts' do
    let (:facts) { {
      :operatingsystem => 'Debian',
      :osfamily        => 'Debian',
      :lsbdistcodename => 'squeeze'
    } }
    let (:params) { {
      :server_opts => ['foo', 'bar', 'baz']
    } }

    it { should contain_concat__fragment('00.dhcp.server.base').with(
        :ensure  => 'present',
        :target  => '/etc/dhcp/dhcpd.conf',
        :content => /log-facility/
      ).with_content(/ddns-update-style none;/).with_content(/#authoritative/).with_content(/foo;\nbar;\nbaz;\n/)
    }
  end
end
