# == Class: koha::user
#
# Create a user for Koha sites to use.
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
define koha::user_name($site_name = $name, $user) {}

define koha::user
(
	$ensure		= "present",

	$koha_lib_dir	= $::koha::params::koha_lib_dir,
	$nologin	= $::koha::params::nologin,

	$user		= $name,
	$full_name	= undef, # Defined in resource body
	$home		= undef  # Defined in resource body
)
{
	unless (defined(Class["::koha::params"]))
	{
		fail("You must define the koha::params class before setting up a Koha user")
	}

	if ($full_name == undef)
	{
		$_full_name = "Koha instance $user"
	}
	else
	{
		$_full_name = $full_name
	}

	if ($home == undef)
	{
		$_home = "$koha_lib_dir/$user"
	}
	else
	{
		$_home = $home
	}

	user
	{ $user:
		ensure		=> $ensure,

		comment		=> $_full_name,
		password	=> "!",

		home		=> $_home,
		shell		=> $nologin,
	}
}
