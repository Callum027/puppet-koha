# == Class: koha::zebra::install
#
# Set up the Koha Zebra indexer service..
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
class koha::zebra::service
(
	$ensure			= "present",
	$zebra_services	= $::koha::params::zebra_services
) inherits koha::params
{
	# This is a temporary requirement, while Zebra is still bound with Koha.
	# TODO: When they are separate packages, they will be able to be started independently.
	if (defined(Class["::koha::service"]))
	{
		Class["::koha::zebra::service"] ~> Service[$zebra_services]
	}
	else
	{
		# Refresh the Apache Service.
		if ($ensure == "present")
		{
			service
			{ $zebra_services:
				ensure	=> "running",
				enable	=> true,
				require	=> Class["::koha::zebra"],
			}
		}
		elsif ($ensure == "absent")
		{
			service
			{ $zebra_services:
				ensure	=> "stopped",
				enable	=> false,
			}
		}
		else
		{
			fail("invalid value for ensure: $ensure")
		}
	}
}
