# == Class: koha::zebra::install
#
# Installation of required packages for Koha, including Apache.
# Also takes care of Apache module configuration, as this is required for
# Koha to be properly installed from the packages.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { koha:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Callum Dickinson <callum@huttradio.co.nz>
#
# === Copyright
#
# Copyright 2015 Callum Dickinson.
#
class koha::zebra::install
(


	$koha_zebra_packages	= $koha::params::koha_packages,
	$koha_zebra_services	= $koha::params::koha_service,
) inherits koha::params
{
	require koha::repo

	# This is a temporary requirement, while Zebra is still bound with Koha.
	# When they are separate packages, they will be able to be installed independently.
	if (Class["koha::install"] == undef)
	{
		package
		{ $koha_zebra_packages:
			ensure	=> installed,
		}

		# Refresh the Apache Service.
		service
		{ $koha_zebra_services:
			ensure	=> running,
			require	=> Package[$koha_zebra_packages],
		}
	}
}
