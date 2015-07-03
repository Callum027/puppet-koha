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
	$site_name				= $name,

	$opac_port
	$intra_port

	# Koha options.
	$koha_user				= undef, # Defined in resource body

	# Apache options.
	$site_intra				= undef, # Defined in resource body

	$memcached_servers			= undef,
	$memcached_namespace			= undef,

	$opac_server_name			= undef, # Defined in resource body
	$intra_server_name			= undef, # Defined in resource body

	$setenv					= undef, # Defined in resource body

	$opac_access_log_file			= undef, # Defined in resource body
	$opac_error_log_file			= undef, # Defined in resource body

	$intranet_access_log_file		= undef, # Defined in resource body
	$intranet_error_log_file		= undef,  # Defined in resource body

	# Database options.
	$db_scheme				= $::koha::params::koha_conf_xml::config_db_scheme,
	$database				= undef, # Defined in resource body
	$db_hostname				= $::koha::params::koha_conf_xml::config_db_scheme,
	$db_port				= undef,
	$db_user				= undef, # Defined in resource body
	$db_password,

	# Zebra options.
	$zebra_server				= undef, # TODO: auto-discover for remote Zebra server

	$zebra_server_biblios_port		= $::koha::params::koha_conf_xml::biblioserver_sru_port,
	$zebra_server_authorities_port		= $::koha::params::koha_conf_xml::authorityserver_sru_port,

	$zebra_server_biblios_database		= $::koha::params::koha_conf_xml::config_biblioserver,
	$zebra_server_authorities_database	= $::koha::params::koha_conf_xml::config_authorityserver,

	$zebra_user				= $::koha::params::zebra_user,
	$zebra_password,

	# koha::params default values.
	$apache_sites_available_dir		= $::koha::params::apache_sites_available_dir,
	$apache_sites_enabled_dir		= $::koha::params::apache_sites_enabled_dir,
	$apache_sites_dir_conf_file_owner	= $::koha::params::apache_sites_dir_conf_file_owner,
	$apache_sites_dir_conf_file_mode	= $::koha::params::apache_sites_dir_conf_file_mode,

	$koha_site_dir				= $::koha::params::koha_site_dir,
	$koha_site_dir_mode			= $::koha::params::koha_site_dir_mode,

	$koha_log_dir				= $::koha::params::koha_log_dir,
	$koha_log_dir_mode			= $::koha::params::koha_log_dir_mode
)
{
	##
	# Resource dependencies.
	##

	unless (defined(Class["::koha"]))
	{
		fail("You must define the Koha base class before using setting up a Koha site")
	}

	##
	# Set default values.
	##

	if ($site_intra == undef)
	{
		$_site_intra = "$site_name-intra"
	}
	else
	{
		$_site_intra = $site_intra
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
		$_mysql_user = $_mysql_db
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
		$_memcached_namespace = "koha_${site_name}"
	}
	else
	{
		$_memcached_namespace = $memcached_namespace
	}

	if ($opac_server_name == undef)
	{
		$_opac_server_name = "${site_name}.${::domain}"
	}
	else
	{
		$_opac_server_name = $opac_server_name
	}

	if ($intra_server_name == undef)
	{
		$_intra_server_name = "${_site_intra}.${::domain}"
	}
	else
	{
		$_intra_server_name = $intra_server_name
	}

	# Apache log files.
	if ($opac_access_log_file == undef)
	{
		$_opac_access_log_file = "${koha_log_dir}/${site_name}/opac-access.log"
	}
	else
	{
		$_opac_access_log_file = $opac_access_log_file
	}

	if ($opac_error_log_file == undef)
	{
		$_opac_error_log_file = "${koha_log_dir}/${site_name}/opac-error.log"
	}
	else
	{
		$_opac_error_log_file = $opac_error_log_file
	}

	if ($intranet_access_log_file == undef)
	{
		$_intranet_access_log_file = "${koha_log_dir}/${site_name}/intranet-access.log"
	}
	else
	{
		$_intranet_access_log_file = $intranet_access_log_file
	}

	if ($intranet_error_log_file == undef)
	{
		$_intranet_error_log_file = "${koha_log_dir}/${site_name}/intranet-error.log"
	}
	else
	{
		$_intranet_error_log_file = $intranet_error_log_file
	}

	if ($ensure == "present")
	{
		$directory_ensure	= "directory"
		$link_ensure		= "link"
	}
	else
	{
		$directory_ensure	= $ensure
		$link_ensure		= $ensure
	}

	##
	# Type validation.
	##

	if ($koha_zebra_sru_hostname != undef)
	{
		if ($koha_zebra_sru_biblios_port == undef)
		{
			fail("Zebra SRU biblios port not defined, but SRU hostname specified")
		}
	}

	##
	# Resource declaration.
	##

	# Generate the Koha user, and the log directory.
	::koha::user
	{ $_koha_user:
		notify	=> Class["::apache::service"],
	}

	file
	{ "$koha_log_dir/$site_name":
		ensure	=> $directory_ensure,
		owner	=> $_koha_user,
		group	=> $_koha_user,
		mode	=> $koha_log_dir_mode,
		require	=> [ Class["::koha"], ::Koha::User[$_koha_user] ],
		notify	=> Class["::apache::service"],
	}

	# Install the Koha configuration file for this site.
	file
	{ "$koha_site_dir/$site_name":
		ensure	=> $directory_ensure,
		owner	=> $_koha_user,
		group	=> $_koha_user,
		mode	=> $koha_site_dir_mode,
		require	=> [ Class["::koha"], ::Koha::User[$_koha_user] ],
		before	=> Class["::apache::service"],
		notify	=> Class["::koha::service"],
	}

	::koha::files::koha_conf_xml::default
	{ $site_name:
		ensure				=> $ensure,

		listen				=> false,
		server				=> false,
		serverinfo			=> false,

		biblioserver			=> false,
		authorityserver			=> false,

		config_db_scheme		=> $db_scheme,
		config_database			=> $_database,
		config_hostname			=> $db_hostname,
		config_port			=> $db_port,
		config_user			=> $_db_user,
		config_pass			=> $db_password,

		serverinfo_user			=> $zebra_user,
		serverinfo_password		=> $zebra_password,

		require				=> [ Class["::koha"], ::Koha::User[$_koha_user], File["$koha_site_dir/$site_name"] ],
		before				=> Class["::apache::service"],
		subscribe			=> Class["::koha::service"],
	}

	# Generate Apache vhosts for the OPAC and Intranet servers for this Koha site.
	file
	{ "$apache_sites_available_dir/$site_name.conf":
		ensure	=> $ensure,
		owner	=> $apache_sites_dir_conf_file_owner,
		group	=> $_koha_user,
		mode	=> $apache_sites_dir_conf_file_mode,
		content	=> template("koha/apache-site.conf.erb"),
		require	=> [ Class["::koha"], File["$koha_site_dir/$site_name"], ::Koha::User[$_koha_user] ],
		before	=> Class["::koha::service"],
		notify	=> Class["::apache::service"],
	}

	file
	{ "$apache_sites_enabled_dir/$site_name.conf":
		ensure	=> $link_ensure,
		target	=> "$apache_sites_available_dir/$site_name.conf",
		owner	=> $apache_sites_dir_conf_file_owner,
		group	=> $_koha_user,
		mode	=> $apache_sites_dir_conf_file_mode,
		require	=> [ Class["::koha"], File[["$koha_site_dir/$site_name", "$apache_sites_available_dir/$site_name.conf"]], ::Koha::User[$_koha_user] ],
		before	=> Class["::koha::service"],
		notify	=> Class["::apache::service"],
	}

	if ($ensure != "present" and $ensure != "absent")
	{
		fail("invalid value for ensure: $ensure")
	}

	# Start the Koha service, if it hasn't been already.
	include koha::service
}
