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
	$ensure				= "present",
	$site_name			= $name,

	$collect_db			= $::koha::params::site_collect_db,
	$collect_elasticsearch		= $::koha::params::site_collect_elasticsearch,
	$collect_memcached		= $::koha::params::site_collect_memcached,
	$collect_zebra			= $::koha::params::site_collect_zebra,

	# Site options.
	$opac_port			= $::koha::params::site_opac_port,
	$intra_port			= $::koha::params::site_intra_port,

	$use_rewrite_log		= $::koha::params::site_use_rewrite_log,

	$opac_error_log			= undef, # Defined in resource body
	$opac_access_log		= undef, # Defined in resource body
	$opac_rewrite_log		= undef, # Defined in resource body

	$intranet_error_log		= undef, # Defined in resource body
	$intranet_access_log		= undef, # Defined in resource body
	$intranet_rewrite_log		= undef, # Defined in resource body

	# Koha options.
	$koha_conf_xml			= undef, # Defined in resource body
	$koha_user			= undef, # Defined in resource body

	# Database options. Automatically collected from other resources.
	$db_db_scheme			= undef,
	$db_database			= undef,
	$db_hostname			= undef,
	$db_port			= undef,
	$db_user			= undef,
	$db_pass			= undef,

	# ElasticSearch options. Automatically collected from other resources.
	$elasticsearch_server		= undef,
	$elasticsearch_index_name	= undef,

	# memcached options. Automatically collected from other resources.
	$memcached_server		= undef,
	$memcached_namespace		= undef,

	# Zebra options. Automatically collected from other resources.
	$zebra_hostname			= undef,
	$zebra_user			= undef,
	$zebra_password			= undef,

	# koha::params default values.
	$koha_site_dir			= $::koha::params::koha_site_dir
)
{
	##
	# Collect and/or configure the servers for each component.
	##

	if ($collect_db == true)
	{
		::Koha::Site::Db <<| site_name == $site_name |>>
	}
	else
	{
		# TODO: PostgreSQL support when Koha supports it.
		validate_re($db_db_scheme, "^mysql$", "the only supported database scheme is 'mysql'")
		#validate_re($db_db_scheme, [ '^mysql$', '^postgresql$' ])

		if (is_string($db_port))
		{
			validate_re($db_port, "^[0-9]*$", "the given parameter is not a valid port number")
		}
		else
		{
			validate_integer($db_port)
		}

		validate_string($db_database, $hostname, $user, $pass)

		::koha::site::db
		{ $site_name:
			db_scheme	=> $db_db_scheme,
			database	=> $db_database,
			hostname	=> $db_hostname,
			port		=> $db_port,
			user		=> $db_user,
			pass		=> $db_pass,
		}
	}

	if ($collect_elasticsearch == true)
	{
		::Koha::Site::Elasticsearch <<| site_name == $site_name |>>
	}
	elsif ($elasticsearch_server != undef)
	{
		validate_string($server, $index_name)

		::koha::site::elasticsearch
		{ $site_name:
			server		=> $elasticsearch_server,
			index_name	=> $elasticsearch_index_name,
		}
	}

	if ($collect_memcached == true)
	{
		::Koha::Site::Memcached <<| site_name == $site_name |>>
	}
	elsif ($memcached_server != undef)
	{
		validate_string($server, $namespace)

		::koha::site::memcached
		{ $site_name:
			server		=> $elasticsearch_server,
			namespace	=> $elasticsearch_namespace,
		}
	}

	if ($collect_zebra == true)
	{
		::Koha::Site::Zebra <<| site_name == $site_name |>>
	}
	else
	{
		validate_string($hostname, $user, $password)

		::koha::site::zebra
		{ $site_name:
			hostname	=> $zebra_hostname,
			user		=> $zebra_user,
			password	=> $zebra_password,	
		}
	}

	##
	# Processed default parameters.
	##

	$_opac_error_log = pick($opac_error_log, "${koha_log_dir}/${site_name}/opac-error.log")
	$_opac_access_log = pick($opac_access_log, "${koha_log_dir}/${site_name}/opac-access.log")
	$_opac_rewrite_log = pick($opac_rewrite_log, "${koha_log_dir}/${site_name}/opac-rewrite.log")

	$_intranet_error_log = pick($intranet_error_log, "${koha_log_dir}/${site_name}/intra-error.log")
	$_intranet_access_log = pick($intranet_access_log, "${koha_log_dir}/${site_name}/intra-access.log")
	$_intranet_rewrite_log = pick($intranet_rewrite_log, "${koha_log_dir}/${site_name}/intra-rewrite.log")


	$_koha_conf_xml = pick($koha_conf_xml, "${koha_site_dir}/${site_name}/koha-conf.xml")
	$_koha_user = pick($koha_user, "$site_name-koha")

	##
	# Resource declaration.
	##

	if ($ensure == "present")
	{
		$directory_ensure = "directory"
	}
	else
	{
		$directory_ensure = $ensure
	}

	# Generate the Koha user, and the log directory.
	::koha::user
	{ $_koha_user:
		notify	=> Class["::apache::service"],
	}

	# Apache vhost for the Koha site.
	::koha::apache::site
	{ $site_name:
		koha_user		=> $_koha_user,
		koha_conf		=> $_koha_conf_xml,

		collect_memcached	=> $collect_memcached,

		require			=> ::Koha::User[$_koha_user],
		before			=> Class["::koha::service"],
		notify			=> Class["::apache::service"],
	}

	# Required folders for configuration and log files.
	::koha::log_dir
	{ $site_name:
		koha_user	=> $_koha_user,
		require		=> Class["::koha"],
		notify		=> Class["::apache::service"],
	}

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

	# Install the koha-conf.xml file for this site.
	::koha::files::koha_conf_xml::default
	{ $site_name:
		ensure				=> $ensure,

		file				=> $_koha_conf_xml,
		file_group			=> $_koha_user,

		listen				=> false,
		server				=> false,
		serverinfo			=> false,

		biblioserver			=> false,
		authorityserver			=> false,

		require				=> [ Class["::koha"], ::Koha::User[$_koha_user], File["$koha_site_dir/$site_name"] ],
		before				=> Class["::apache::service"],
		notify				=> Class["::koha::service"],
	}

	
	# Start the Koha service, if it hasn't been already.
	include koha::service
}
