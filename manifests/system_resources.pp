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
class koha::system_resources
(
	$ensure			= "present",

	# koha::params default values.
	$koha_dir_owner		= $::koha::params::koha_dir_owner,
	$koha_dir_group		= $::koha::params::koha_dir_group,
	$koha_dir_mode		= $::koha::params::koha_dir_mode,

	$koha_config_dir	= $::koha::params::koha_config_dir,
	$koha_doc_dir		= $::koha::params::koha_doc_dir,
	$koha_lib_dir		= $::koha::params::koha_lib_dir,
	$koha_log_dir		= $::koha::params::koha_log_dir,

	$koha_run_dir		= $::koha::params::koha_run_dir,
	$koha_share_dir		= $::koha::params::koha_share_dir,

	$koha_site_dir		= $::koha::params::koha_site_dir,
	$koha_spool_dir		= $::koha::params::koha_spool_dir
)
{
	##
	# Processed default parameters.
	##
	if ($ensure == "present")
	{
		$directory_ensure = "directory"
	}
	else
	{
		$directory_ensure = $ensure
	}

	##
	# Resource declaration.
	##

	file
	{ [ $koha_config_dir, $koha_doc_dir, $koha_lib_dir,
			$koha_log_dir, $koha_run_dir, $koha_share_dir,
			$koha_site_dir, $koha_spool_dir ]:
		ensure	=> $directory_ensure,
		owner	=> $koha_dir_owner,
		group	=> $koha_dir_group,
		mode	=> $koha_dir_mode,
	}

	package
	{ "mysql2":
		provider	=> "gem",
		ensure		=> $ensure,
	}
}
