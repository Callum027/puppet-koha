# == Class: koha::site
#
# Set up a Koha site instance.
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
define koha::log_dir
(
	$ensure			= "present",

	$site_name		= $name,
	$koha_user,

	$koha_log_dir		= $::koha::params::koha_log_dir,
	$koha_log_dir_mode	= $::koha::params::koha_log_dir_mode,
)
{
	unless (defined(Class["::koha"]))
	{
		fail("You must define the Koha base class before using setting up a Koha site")
	}

	if ($ensure == "present")
	{
		$directory_ensure	= "directory"
	}
	else
	{
		$directory_ensure	= $ensure
	}

	file
	{ "$koha_log_dir/$site_name":
		ensure	=> $directory_ensure,
		owner	=> $koha_user,
		group	=> $koha_user,
		mode	=> $koha_log_dir_mode,
	}

	if ($ensure != "present" and $ensure != "absent")
	{
		fail("invalid value for ensure: $ensure")
	}
}
