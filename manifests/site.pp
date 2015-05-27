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

	$koha_config_dir			= $::koha::params::koha_config_dir,
	$koha_site_dir				= $::koha::params::koha_site_dir,
	$koha_site_opac_port			= $::koha::params::koha_site_opac_port,
	$koha_site_intra_port			= $::koha::params::koha_site_intra_port,

	$koha_lib_dir				= $::koha::params::koha_lib_dir,
	$koha_log_dir				= $::koha::params::koha_log_dir,
	$koha_plugins_dir			= undef, # Defined in resource body

	$koha_zebra_biblios_config		= $::koha::params::koha_zebra_biblios_config,
	$koha_zebra_authorities_config		= $::koha::params::koha_zebra_authorities_config,

	$koha_zebra_biblios_indexing_mode	= $::koha::params::koha_zebra_biblios_indexing_mode,
	$koha_zebra_authorities_indexing_mode	= $::koha::params::koha_zebra_authorities_indexing_mode,

	$koha_zebra_marc_format			= $::koha::params::koha_zebra_marc_format,

	$koha_zebra_sru_hostname		= undef,
	$koha_zebra_sru_biblios_port		= undef,

	$site_name				= $name,
	$site_intra				= undef, # Defined in resource body
	$site_user				= undef, # Defined in resource body
	$site_group				= undef, # Defined in resource body

	$koha_user				= undef, # Defined in resource body
	$zebra_password,

	$mysql_db				= undef, # Defined in resource body
	$mysql_hostname				= "localhost",
	$mysql_port				= "3306",
	$mysql_user				= undef, # Defined in resource body
	$mysql_password,

	$memcached_servers			= undef,
	$memcached_namespace			= undef,

	$opac_server_name			= undef, # Defined in resource body
	$intra_server_name			= undef, # Defined in resource body

	$setenv					= undef, # Defined in resource body

	$opac_access_log_file			= undef, # Defined in resource body
	$opac_error_log_file			= undef, # Defined in resource body

	$intranet_acess_log_file		= undef, # Defined in resource body
	$intranet_error_log_file		= undef  # Defined in resource body
)
{
	unless (defined(Class["::koha"]))
	{
		fail("You must define the Koha base class before using setting up a Koha site")
	}

	# Set up the Koha service if it hasn't already.
	include ::koha::service

	# Define default parameters that can't be defined in the resource parameter list,
	# if they haven't been defined by the user.
	if ($koha_plugins_dir == undef)
	{
		$_koha_plugins_dir_ = "$koha_lib_dir/$site_name/plugins"
	}
	else
	{
		$_koha_plugins_dir_ = $koha_plugins_dir
	}

	if ($koha_zebra_sru_hostname != undef)
	{
		if ($koha_zebra_sru_biblios_port == undef)
		{
			fail("Zebra SRU biblios port not defined, but SRU hostname specified")
		}
	}

	if ($site_intra == undef)
	{
		$_site_intra = "$site_name-intra"
	}
	else
	{
		$_site_intra = $site_intra
	}

	if ($site_user == undef)
	{
		$_site_user = "$site_name-koha"
	}
	else
	{
		$_site_user = $site_user
	}

	if ($site_group == undef)
	{
		$_site_group = "$site_name-koha"
	}
	else
	{
		$_site_group = $site_group
	}

	if ($koha_user == undef)
	{
		$_koha_user = "$site_name-koha"
	}
	else
	{
		$_koha_user = $koha_user
	}

	if ($mysql_db == undef)
	{
		$_mysql_db = "koha_$site_name"
	}
	else
	{
		$_mysql_db = $mysql_db
	}

	if ($mysql_user == undef)
	{
		$_mysql_user = $mysql_db
	}
	else
	{
		$_mysql_user = $mysql_user
	}

	if (is_array($memcached_servers))
	{
		$_memcached_servers = join($memcached_servers, ",")
	}
	elsif (is_string($memcached_servers))
	{
		$_memcached_servers = $memcached_servers
	}
	else
	{
		$_memcached_servers = ""
	}

	if ($memcached_namespace == undef)
	{
		$_memcached_namespace = "koha_$site_name"
	}
	else
	{
		$_memcached_namespace = $memcached_namespace
	}

	if ($opac_server_name == undef)
	{
		$_opac_server_name = "$site_name.$::domain"
	}
	else
	{
		$_opac_server_name = $opac_server_name
	}

	if ($intra_server_name == undef)
	{
		$_intra_server_name = "$site_intra_.$::domain"
	}
	else
	{
		$_intra_server_name = $intra_server_name
	}

	# Apache log files.
	if ($opac_access_log_file == undef)
	{
		$_opac_access_log_file = "koha/$site_name/opac-access.log"
	}
	else
	{
		$_opac_access_log_file = $opac_access_log_file
	}

	if ($intranet_error_log_file == undef)
	{
		$_opac_error_log_file_ = "koha/$site_name/opac-error.log"
	}
	else
	{
		$_opac_error_log_file = $opac_error_log_file
	}

	if ($intranet_access_log_file == undef)
	{
		$_intranet_access_log_file = "koha/$site_name/intranet-access.log"
	}
	else
	{
		$_intranet_access_log_file = $intranet_access_log_file
	}

	if ($intranet_error_log_file == undef)
	{
		$_intranet_error_log_file = "koha/$site_name/intranet-error.log"
	}
	else
	{
		$_intranet_error_log_file = $intranet_error_log_file
	}

	if ($setenv == undef)
	{
		$_setenv = [ "KOHA_CONF \"$koha_site_dir/$site_name/koha-conf.xml\"", "MEMCACHED_SERVERS \"$memcached_servers_\"", "MEMCACHED_NAMESPACE \"$memcached_namespace_\"" ]
	}
	else
	{
		$_setenv = $setenv
	}

	# Generate the Koha user.
	::koha::user { $_koha_user: }

	# Install the Koha configuration file for this site.
	if ($ensure == "present")
	{
		$directory_ensure = "directory"
	}
	else
	{
		$directory_ensure = $ensure
	}

	file
	{ "$koha_site_dir/$site_name":
		ensure	=> $directory_ensure,
		owner	=> $_koha_user,
		group	=> $_koha_user,
		mode	=> 755,
		require	=> [ Class["::koha"], ::Koha::User[$_koha_user] ],
	}

	file
	{ "$koha_site_dir/$site_name/koha-conf.xml":
		ensure	=> $ensure,
		owner	=> "root",
		group	=> $_koha_user,
		mode	=> 640,
		content	=> template("koha/koha-conf-site.xml.erb"),
		require	=> [ Class["::koha"], File["$koha_site_dir/$site_name"], ::Koha::User[$_koha_user] ],
		notify	=> Class["::koha::service"],
	}

	# Generate Apache vhosts for the OPAC and Intranet servers for this Koha site.
	::apache::vhost
	{ $_opac_server_name:
		ensure			=> $ensure,

		docroot			=> undef,
		manage_docroot		=> false,

		additional_includes	=>
		[
   			"$koha_config_dir/apache-shared.conf",
			# "$koha_config_dir/apache-shared-disable.conf",
   			"$koha_config_dir/apache-shared-opac.conf"
		],

		setenv			=> $_setenv,

		itk			=>
		{
			user	=> $_site_user,
			group	=> $_site_group,
		},

		access_log_file		=> $_opac_access_log_file,
		error_log_file		=> $_opac_error_log_file,
		# This Apache configuration option is not available in puppetlabs/apache:
		#  RewriteLog  koha/$site_name/intranet-rewrite.log

		require			=> Class["::koha"],
		notify			=> Class["::koha::service"],
	}

	::apache::vhost
	{ $_intra_server_name:
		ensure			=> $ensure,

		docroot			=> undef,
		manage_docroot		=> false,

		additional_includes	=>
		[
   			"$koha_config_dir/apache-shared.conf",
			# "$koha_config_dir/apache-shared-disable.conf",
   			"$koha_config_dir/apache-shared-intranet.conf"
		],

		setenv			=> $_setenv,

		itk			=>
		{
			user	=> $_site_user,
			group	=> $_site_group,
		},

		access_log_file		=> $_intranet_access_log_file,
		error_log_file		=> $_intranet_error_log_file,
		# This Apache configuration option is not available in puppetlabs/apache:
		#  RewriteLog  koha/$site_name/intranet-rewrite.log

		require			=> Class["::koha"],
		notify			=> Class["::koha::service"],
	}

	if ($ensure != "present" and $ensure != "absent")
	{
		fail("invalid value for ensure: $ensure")
	}
}
