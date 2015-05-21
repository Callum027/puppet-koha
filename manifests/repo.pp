# == Class: koha::repo
#
# Set up the Koha APT repository.
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
class koha::repo
(
	$ensure			= "present",
	$koha_repo_release	= $::koha::params::koha_repo_release
) inherits koha::params
{
	# Prepare the package manager with the Koha repository.
	case $::osfamily
	{
		"Debian":
		{
			::apt::source
			{ "koha":
				ensure		=> $ensure,
				location	=> "http://debian.koha-community.org/koha",
				release		=> $koha_repo_release,
				repos		=> "main",
				key		=> "3EA44636DBCE457DA2CF8D823C9356BBA2E41F10",
				key_source	=> "http://debian.koha-community.org/koha/gpg.asc",
			}
		}

		# RedHat support will come at a later time!

		default:
		{
			fail("Sorry, but the koha module does not support the $::osfamily OS family at this time")
		}
	}

	if ($ensure != "present" and $ensure != "absent")
	{
		fail("invalid value for ensure: $ensure")
	}
}
