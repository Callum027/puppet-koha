# == Class: koha::zebra::install
#
# Installation of the Koha Zebra indexer packages.
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
	$ensure			= "present",
	$koha_zebra_services	= $::koha::params::koha_service
) inherits koha::params
{
	# Install the Koha repository.
	unless (defined(Class["::koha::repo"]))
	{
		class
		{ "::koha::repo":
			ensure	=> $ensure,
		}

		contain "::koha::repo"
	}

	# This is a temporary requirement, while Zebra is still bound with Koha.
	# TODO: When they are separate packages, they will be able to be installed independently.
	unless (defined(Class["::koha::install"]))
	{
		if ($ensure == "present")
		{
			package
			{ $koha_zebra_packages:
				ensure	=> "installed",
			}
		}
		elsif ($ensure == "absent")
		{
			package
			{ $koha_zebra_packages:
				ensure	=> "purged",
			}
		}
		else
		{
			fail("invalid value for ensure: $ensure")
		}
	}
}
