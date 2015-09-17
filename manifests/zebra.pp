# == Class: koha::zebra
#
# Configure the Koha Zebra indexer.
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
class koha::zebra($ensure = "present")
{
	require ::koha::params

	# Include other related resources used by other parts of the module.
	include ::koha::system_resources

	##
	# Defined resources.
	##
	unless (defined(Class["::koha::zebra::install"]))
	{
		class
		{ "::koha::zebra::install":
			ensure	=> $ensure,
		}
	}

	unless (defined(Class["::koha::zebra::service"]))
	{
		class
		{ "::koha::zebra::service":
			ensure	=> $ensure,
		}
	}

	##
	# Dependency chains.
	##
	Class["::koha::zebra::install"] -> Class["::koha::system_resources"]
	Class["::koha::zebra::install"] -> Class["::koha::zebra::service"]
}
