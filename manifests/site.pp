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
	$ensure					= "present",

	$koha_services				= undef,

	$koha_config_dir			= undef,
	$koha_site_dir				= undef,
	$koha_site_opac_port			= undef,
	$koha_site_intra_port			= undef,

	$koha_log_dir				= undef,
	$koha_plugins_dir			= undef,

	$koha_zebra_biblios_config		= undef,
	$koha_zebra_authorities_config		= undef,

	$koha_zebra_biblios_indexing_mode	= undef,
	$koha_zebra_authorities_indexing_mode	= undef,

	$koha_zebra_marc_format			= undef,

	$koha_zebra_sru_hostname		= undef,
	$koha_zebra_sru_biblios_port		= undef,

	$site_name				= $name,
	$site_intra				= "$site_name-intra",
	$site_user				= "$site_name-koha",
	$site_group				= "$site_name-koha",

	$koha_user				= "$site_name-koha",
	$zebra_password,

	$mysql_db				= "koha_$site_name",
	$mysql_hostname				= "localhost",
	$mysql_port				= "3306",
	$mysql_user				= $mysql_db,
	$mysql_password,

	$memcached_servers			= [],
	$memcached_namespace			= "koha_$site_name",

	$opac_server_name			= "$site_name.$fqdn",
	$intra_server_name			= "$site_intra.$fqdn",

	$setenv					= undef,
	$error_log_file				= undef
)
{
	require koha::params
	require koha::install

	# Define default parameters, if they haven't been defined by the user.
	if ($koha_services == undef)
	{
		$koha_services_real = $koha::params::koha_services
	}
	else
	{
		$koha_services_real = $koha_services
	}

	if ($koha_config_dir == undef)
	{
		$koha_config_dir_real = $koha::params::koha_config_dir
	}
	else
	{
		$koha_config_dir_real = $koha_config_dir
	}

	if ($koha_site_dir == undef)
	{
		$koha_site_dir_real = $koha::params::koha_site_dir
	}
	else
	{
		$koha_site_dir_real = $koha_site_dir
	}

	if ($koha_site_opac_port == undef)
	{
		$koha_site_opac_port_real = $koha::params::koha_site_opac_port
	}
	else
	{
		$koha_site_opac_port_real = $koha_site_opac_port
	}

	if ($koha_site_intra_port == undef)
	{
		$koha_site_intra_port_real = $koha::params::koha_site_intra_port
	}
	else
	{
		$koha_site_intra_port_real = $koha_site_intra_port
	}

	if ($koha_log_dir == undef)
	{
		$koha_log_dir_real = $koha::params::koha_log_dir
	}
	else
	{
		$koha_log_dir_real = $koha_log_dir
	}

	if ($koha_plugins_dir == undef)
	{
		$koha_plugins_dir_real = "/var/lib/koha/$site_name/plugins"
	}

	if ($koha_zebra_biblios_config == undef)
	{
		$koha_zebra_biblios_config_real = $koha::params::koha_zebra_biblios_config
	}
	else
	{
		$koha_zebra_biblios_config_real = $koha_zebra_biblios_config
	}

	if ($koha_zebra_biblios_indexing_mode == undef)
	{
		$koha_zebra_biblios_indexing_mode_real = $koha::params::koha_zebra_biblios_indexing_mode
	}
	else
	{
		$koha_zebra_biblios_indexing_mode_real = $koha_zebra_biblios_indexing_mode
	}

	if ($koha_zebra_authorities_indexing_mode == undef)
	{
		$koha_zebra_authorities_indexing_mode_real = $koha::params::koha_zebra_authorities_indexing_mode
	}
	else
	{
		$koha_zebra_authorities_indexing_mode_real = $koha_zebra_authorities_indexing_mode
	}

	if ($koha_zebra_marc_format == undef)
	{
		$koha_zebra_marc_format_real = $koha::params::koha_zebra_marc_format
	}
	else
	{
		$koha_zebra_marc_format_real = $koha_zebra_marc_format
	}

	if ($koha_zebra_sru_hostname != undef)
	{
		if ($koha_zebra_sru_biblios_port == undef)
		{
			fail("Zebra SRU biblios port not defined, but SRU hostname specified")
		}
	}

	if ($error_log_file == undef)
	{
		$error_log_file_real = "$koha_log_dir_real/$site_name/intranet-error.log"
	}

	if ($setenv == undef)
	{
		$setenv_real = [ "KOHA_CONF \"$koha_site_dir_real/$site_name/koha-conf.xml\"", "MEMCACHED_NAMESPACE \"$memcached_namespace\"" ]
	}

	# Install the Koha configuration file for this site.
	file
	{ "$koha_config_dir_real/koha-conf.xml":
		ensure	=> $ensure,
		owner	=> "root",
		group	=> $koha_user,
		mode	=> 640,
		content	=> template("koha/koha-conf-site.xml.erb"),
		notify	=> Service[$koha_services_real],
	}

	# Generate Apache vhosts for the OPAC and Intranet servers for this Koha site.
	apache::vhost
	{ $opac_server_name:
		ensure			=> $ensure,

		additional_includes	=>
		[
   			"$koha_config_dir_real/apache-shared.conf",
			# "$koha_config_dir_real/apache-shared-disable.conf",
   			"$koha_config_dir_real/apache-shared-opac.conf"
		],

		setenv			=> $setenv_real,
		memcache_servers	=> $memcached_servers,

		itk			=>
		{
			user	=> $site_user,
			group	=> $site_group,
		},

		error_log_file		=> $error_log_file_real,
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

		setenv			=> $setenv_real,
		memcache_servers	=> $memcached_servers,

		itk			=>
		{
			user	=> $site_user,
			group	=> $site_group,
		},

		error_log_file		=> $error_log_file_real,
		# These Apache configuration options are not available in puppetlabs/apache:
		#  TransferLog /var/log/koha/$site_name/intranet-access.log
		#  RewriteLog  /var/log/koha/$site_name/intranet-rewrite.log
	}
}
