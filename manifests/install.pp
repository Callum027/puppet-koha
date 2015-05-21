# == Class: koha::install
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
class koha::install
(
	$ensure			= "present",

	$koha_packages		= $::koha::params::koha_packages
) inherits koha::params
{
	# Install the Koha repository.
	unless (defined(Class["::koha::repo"]))
	{
		class
		{ "koha::repo":
			ensure	=> $ensure,
		}

		contain "::koha::repo"
	}

	# A MySQL client is required for Koha to access the library databases.
	unless ($ensure != "present" or defined(Class["::mysql::client"]))
	{
		contain ::mysql::client
	}

	# Install Apache first, before installing Koha, so we can disable the event MPM.
	# Koha uses the ITK MPM, and the libapache2-mod-itk package for Ubuntu does not always
	# install properly with that MPM enabled. This will work around that problem.
	if ($ensure == "present")
	{
		class
		{ "::apache":
			mpm_module	=> "itk",
		}

		contain "::apache"

		::apache::mod { "cgi": }
		contain ::apache::mod::rewrite
	}

	# Do the job!
	if ($ensure == "present")
	{
		package
		{ $koha_packages:
			ensure	=> "installed",
			require	=> Class[[ "::koha::repo", "::apache" ]],
		}
	}
	elsif ($ensure == "absent")
	{
		package
		{ $koha_packages:
			ensure	=> "purged",
			require	=> Class["::koha::repo"],
		}
	}
	else
	{
		fail("invalid value for ensure: $ensure")
	}
}
