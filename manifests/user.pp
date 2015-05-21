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
define koha::user
(
	$ensure = "present",

	$koha_lib_dir = undef,

	$username = undef,
	$full_name = undef,
	$home = undef,

	$nologin = undef
)
{
	# TODO: Proper dependency ordering for koha::params, to get rid of this $x_real BS.
	require koha::params

	if ($username == undef)
	{
		$username_real = "$name-koha"
	}
	else
	{
		$username_real = $username
	}

	if ($full_name == undef)
	{
		$full_name_real = "Koha instance $username"
	}
	else
	{
		$full_name_real = $full_name
	}

	if ($koha_lib_dir == undef)
	{
		$koha_lib_dir_real = $koha::params::koha_lib_dir
	}
	else
	{
		$koha_lib_dir_real = $koha_lib_dir
	}

	if ($home == undef)
	{
		$home_real = "$koha_lib_dir_real/$username_real"
	}
	else
	{
		$home_real = $home
	}

	if ($nologin == undef)
	{
		$nologin_real = $koha::params::nologin
	}
	else
	{
		$nologin_real = $nologin
	}

	user
	{ $username:
		ensure		=> $ensure,

		comment		=> $full_name_real,
		password	=> "!",

		home		=> $home_real,
		shell		=> $nologin_real,
	}
}
