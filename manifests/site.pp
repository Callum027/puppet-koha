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
define koha::site
(
	$ensure			= "present",

	$koha_site_dir		= undef,
	$koha_site_opac_port	= undef,
	$koha_site_intra_port	= undef,

	$site_name		= $name,
	$site_intra		= "$site_name-intra",
	$site_user		= "$site_name-koha",
	$site_group		= "$site_name-koha",

	$memcached_servers	= [],
	$memcached_namespace	= "koha_$site_name",

	$opac_server_name	= "$site_name.$fqdn",
	$intra_server_name	= "$site_intra.$fqdn",

	$setenv			= undef,
	$error_log_file		= undef
) inherits koha::params
{
	# Define default parameters, if they haven't been defined by the user.
	if ($koha_config_dir == undef)
	{
		$koha_config_dir = $koha::params::koha_config_dir
	}

	if ($koha_log_dir == undef)
	{
		$koha_log_dir = $koha::params::koha_log_dir
	}

	if ($koha_site_dir == undef)
	{
		$koha_site_dir = $koha::params::koha_site_dir
	}

	if ($koha_site_opac_port == undef)
	{
		$koha_site_opac_port = $koha::params::koha_site_opac_port
	}

	if ($koha_site_intra_port == undef)
	{
		$koha_site_intra_port = $koha::params::koha_site_intra_port
	}

	if ($error_log_file == undef)
	{
		$error_log_file = "$koha_log_dir/$site_name/intranet-error.log",
	}

	if ($setenv == undef)
	{
		$setenv = [ "KOHA_CONF \"$koha_site_dir/$site_name/koha-conf.xml\"", "MEMCACHED_NAMESPACE \"$memcached_namespace\"" ],
	}

	# Generate Apache vhosts for the OPAC and Intranet servers for this Koha site.
	apache::vhost
	{ $opac_server_name:
		ensure			=> $ensure,

		additional_includes	=>
		[
   			"$koha_config_dir/apache-shared.conf",
			# "$koha_config_dir/apache-shared-disable.conf",
   			"$koha_config_dir/apache-shared-opac.conf"
		],

		setenv			=> $setenv,
		memcache_servers	=> $memcached_servers,

		itk			=>
		{
			user	=> $site_user,
			group	=> $site_group,
		},

		error_log_file		=> $error_log_file,
		# These Apache configuration options are not available in puppetlabs/apache:
		#  TransferLog /var/log/koha/$site_name/opac-access.log
		#  RewriteLog  /var/log/koha/$site_name/opac-rewrite.log
	}

	apache::vhost
	{ $intra_server_name:
		ensure			=> $ensure,

		additional_includes	=>
		[
   			"$koha_config_dir/apache-shared.conf",
			# "$koha_config_dir/apache-shared-disable.conf",
   			"$koha_config_dir/apache-shared-intranet.conf"
		],

		setenv			=> $setenv,
		memcache_servers	=> $memcached_servers,

		itk			=>
		{
			user	=> $site_user,
			group	=> $site_group,
		},

		error_log_file		=> $error_log_file,
		# These Apache configuration options are not available in puppetlabs/apache:
		#  TransferLog /var/log/koha/$site_name/intranet-access.log
		#  RewriteLog  /var/log/koha/$site_name/intranet-rewrite.log
	}
}
