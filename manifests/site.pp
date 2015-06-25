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

	# Apache options.
	$apache_sites_available_dir		= $::koha::params::apache_sites_available_dir,
	$apache_sites_enabled_dir		= $::koha::params::apache_sites_enabled_dir,
	$apache_sites_dir_conf_file_mode	= $::koha::params::apache_sites_dir_conf_file_mode,

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

	# Global koha-conf.xml options.
	$koha_user				= undef, # Defined in resource body
	$koha_zebra_password,

	$koha_config_dir			= $::koha::params::koha_config_dir,
	$koha_site_dir				= $::koha::params::koha_site_dir,
	$koha_site_dir_mode			= $::koha::params::koha_site_dir_mode,
	$koha_site_dir_conf_file_mode		= $::koha::params::koha_site_dir_conf_file_mode,
	$koha_site_opac_port			= $::koha::params::koha_site_opac_port,
	$koha_site_intra_port			= $::koha::params::koha_site_intra_port,

	$koha_lib_dir				= $::koha::params::koha_lib_dir,
	$koha_log_dir				= $::koha::params::koha_log_dir,
	$koha_log_dir_mode			= $::koha::params::koha_log_dir_mode,

	$koha_zebra_biblios_config		= $::koha::params::koha_zebra_biblios_config,
	$koha_zebra_authorities_config		= $::koha::params::koha_zebra_authorities_config,

	$koha_zebra_biblios_indexing_mode	= $::koha::params::koha_zebra_biblios_indexing_mode,
	$koha_zebra_authorities_indexing_mode	= $::koha::params::koha_zebra_authorities_indexing_mode,

	$koha_zebra_marc_format			= $::koha::params::koha_zebra_marc_format,

	$koha_zebra_server_biblios_port		= $::koha::params::koha_zebra_sru_biblios_port,

	$koha_zebra_server_authorities_port	= $::koha::params::koha_zebra_sru_authorities_port,

	$koha_zebra_biblioserver		= $::koha::params::koha_zebra_biblioserver,
	$koha_zebra_authorityserver		= $::koha::params::koha_zebra_authorityserver,

	# koha-conf.xml options specific to the koha::site class.
	$mysql_db				= undef, # Defined in resource body
	$mysql_hostname				= "localhost",
	$mysql_port				= "3306",
	$mysql_user				= undef, # Defined in resource body
	$mysql_password,

	$koha_zebra_server			= undef # TODO: auto-discover for remote Z39.50 server
)
{
	unless (defined(Class["::koha"]))
	{
		fail("You must define the Koha base class before using setting up a Koha site")
	}

	if ($koha_zebra_server != undef)
	{
		$_koha_zebra_biblioserver = "tcp:$koha_zebra_server:$koha_zebra_server_biblios_port/$koha_zebra_biblioserver"
		$_koha_zebra_authorityserver = "tcp:$koha_zebra_server:$koha_zebra_server_autorities_port/$koha_zebra_authorityserver"
	}
	else
	{
		$_koha_zebra_biblioserver = $koha_zebra_biblioserver
		$_koha_zebra_authorityserver = $koha_zebra_authorityserver
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
		$_intra_server_name = "$_site_intra.$::domain"
	}
	else
	{
		$_intra_server_name = $intra_server_name
	}

	# Apache log files.
	if ($opac_access_log_file == undef)
	{
		$_opac_access_log_file = "$koha_log_dir/$site_name/opac-access.log"
	}
	else
	{
		$_opac_access_log_file = $opac_access_log_file
	}

	if ($opac_error_log_file == undef)
	{
		$_opac_error_log_file = "$koha_log_dir/$site_name/opac-error.log"
	}
	else
	{
		$_opac_error_log_file = $opac_error_log_file
	}

	if ($intranet_access_log_file == undef)
	{
		$_intranet_access_log_file = "$koha_log_dir/$site_name/intranet-access.log"
	}
	else
	{
		$_intranet_access_log_file = $intranet_access_log_file
	}

	if ($intranet_error_log_file == undef)
	{
		$_intranet_error_log_file = "$koha_log_dir/$site_name/intranet-error.log"
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

	# Add global configuration options to koha-conf.xml, if it has not been defined already.
	unless (defined(::Koha::Files::Koha_conf_xml_site[$site_name]))
	{
		::koha::files::koha_conf_xml_site
		{ $site_name:
			# Global parameters.
			koha_user				=> $_koha_user,
			koha_zebra_password			=> $koha_zebra_password,

			koha_config_dir				=> $koha_config_dir,
			koha_site_dir				=> $koha_site_dir,
			koha_site_dir_conf_file_mode		=> $koha_site_dir_conf_file_mode,
			koha_lib_dir				=> $koha_lib_dir,
			koha_log_dir				=> $koha_log_dir,
			koha_log_dir_mode			=> $koha_log_dir_mode,

			koha_zebra_biblios_config		=> $koha_zebra_biblios_config,
			koha_zebra_authorities_config		=> $koha_zebra_authorities_config,

			koha_zebra_biblios_indexing_mode	=>$koha_zebra_biblios_indexing_mode,
			koha_zebra_authorities_indexing_mode	=>$koha_zebra_authorities_indexing_mode,

			koha_zebra_marc_format			=> $koha_zebra_marc_format,

			koha_zebra_server_biblios_port		=> $koha_zebra_server_biblios_port,
			koha_zebra_server_authorities_port	=> $koha_zebra_server_authorities_port,

			koha_zebra_biblioserver			=> $koha_zebra_biblioserver,
			koha_zebra_authorityserver		=> $koha_zebra_authorityserver,
		}
	}

	# Establish the relationship between Koha package installation, koha-conf.xml
	# and the Apache and Koha services.
	Class["::koha"] -> ::Koha::Files::Koha_conf_xml_site[$site_name]
	::Koha::Files::Koha_conf_xml_site[$site_name] -> Class["::apache::service"]
	::Koha::Files::Koha_conf_xml_site[$site_name] ~> Class["::koha::service"]

	# Parameters specific to koha::site.
	::Koha::Files::Koha_conf_xml_site <| name == $site_name |>
	{
		mysql_db		=> $_mysql_db,
		mysql_hostname		=> $mysql_hostname,
		mysql_port		=> $mysql_port,
		mysql_user		=> $_mysql_user,
		mysql_password		=> $mysql_password,

		koha_zebra_server	=> $koha_zebra_server,
	}

	# Generate Apache vhosts for the OPAC and Intranet servers for this Koha site.
	file
	{ "$apache_sites_available_dir/$site_name.conf":
		ensure	=> $ensure,
		owner	=> "root",
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
		owner	=> "root",
		group	=> $_koha_user,
		mode	=> 640,
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
