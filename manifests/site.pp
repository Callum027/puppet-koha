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

	$elasticsearch			= undef, # TODO: Automatically determine from collected resources. Default to false otherwise.

	$collect_db			= $::koha::params::site_collect_db,
	$collect_elasticsearch		= $::koha::params::site_collect_elasticsearch,
	$collect_memcached		= $::koha::params::site_collect_memcached,
	$collect_zebra			= $::koha::params::site_collect_zebra,

	# Koha options.
	$koha_conf_xml			= undef, # Defined in resource body
	$koha_user			= undef, # Defined in resource body

	# Database options. Automatically collected from other resources.
	$db_scheme			= undef,
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
	# Collect the servers for each component.
	##

	if ($collect_db == true)
	{
		$db_servers = query_facts("Koha::Db::Site[$site_name]"), [ "scheme", "database", "port", "user", "pass" ])
		$db_servers_array = any2array($db_servers)

		$db_server = merge({ "hostname" =>  $db_servers_array[0] }, $db_servers_array[1])
	}

	if ($collect_elasticsearch == true)
	{
		$elasticsearch_servers = query_facts("Koha::Elasticsearch::Site[$site_name]", [ "index_name" ])
	}

	if ($collect_memcached == true)
	{
		$memcached_servers = query_facts("Koha::Memcached::Site[$site_name]", [ "namespace" ])
	}

	if ($collect_zebra == true)
	{
		$zebra_servers = query_facts("Koha::Zebra::Site[$site_name]", [ "user", "password" ])
		$zebra_servers_array = any2array($zebra_servers)

		$zebra_server = merge({ "hostname" =>  $zebra_servers_array[0] }, $zebra_servers_array[1])
	}

	##
	# Collected parameters.
	##

	# Database options.
	if ($db_scheme != undef)
	{
		$_db_scheme = $db_scheme
	}
	else
	{
		if ($collect_db == true)
		{
			$_db_scheme = $db_server["scheme"]
		}
		else
		{
			fail("resource collection disabled for db, parameter required for \$db_scheme")
		}
	}

	if ($db_database != undef)
	{
		$_db_database = $db_database
	}
	else
	{
		if ($collect_db == true)
		{
			$_db_database = $db_server["database"]
		}
		else
		{
			fail("resource collection disabled for db, parameter required for \$db_database")
		}
	}

	if ($db_hostname != undef)
	{
		$_db_hostname = $db_hostname
	}
	else
	{
		if ($collect_db == true)
		{
			$_db_hostname = $db_server["hostname"]
		}
		else
		{
			fail("resource collection disabled for db, parameter required for \$db_hostname")
		}
	}

	if ($db_port != undef)
	{
		$_db_port = $db_port
	}
	else
	{
		if ($collect_db == true)
		{
			$_db_port = $db_server["port"]
		}
		else
		{
			fail("resource collection disabled for db, parameter required for \$db_port")
		}
	}

	if ($db_user != undef)
	{
		$_db_user = $db_user
	}
	else
	{
		if ($collect_db == true)
		{
			$_db_user = $db_server["user"]
		}
		else
		{
			fail("resource collection disabled for db, parameter required for \$db_user")
		}
	}

	if ($db_pass != undef)
	{
		$_db_pass = $db_pass
	}
	else
	{
		if ($collect_db == true)
		{
			$_db_pass = $db_server["pass"]
		}
		else
		{
			fail("resource collection disabled for db, parameter required for \$db_pass")
		}
	}

	# ElasticSearch options.
	# TODO for ElasticSearch: Load installer/data/mysql/elasticsearch_mapping.sql into your database
	#                         Set the 'SearchEngine' system preference to 'Elasticsearch' 
	if ($elasticsearch_server != undef)
	{
		$_elasticsearch_server = $elasticsearch_server
	}
	else
	{
		if ($collect_elasticsearch == true)
		{
			$_elasticsearch_server = keys($elasticsearch_servers)
		}
		elsif ($elasticsearch == true)
		{
			fail("resource collection disabled for elasticsearch while elasticsearch is enabled, parameter required for \$elasticsearch_server")
		}
	}

	if ($elasticsearch_index_name != undef)
	{
		$_elasticsearch_index_name = $elasticsearch_index_name
	}
	else
	{
		if ($collect_elasticsearch == true)
		{
			$elasticsearch_index_names = split(inline_template("<%- @elasticsearch_servers.each do |h, v| -%><%= v[index_name] %><%- end -%>"), "\n")

			if (size($elasticsearch_index_names) > 1)
			{
				fail("found more than one value for \$elasticsearch_index_name for $site_name (only one is possible): $elasticsearch_index_names")
			}
			elsif (size($elasticsearch_index_names) < 1)
			{
				fail("could not find value for \$elasticsearch_index_name for $site_name")
			}

			$_elasticsearch_index_name = join($elasticsearch_index_names, ",")
		}
		elsif ($elasticsearch == true)
		{
			fail("resource collection disabled for elasticsearch while elasticsearch is enabled, parameter required for \$elasticsearch_index_name")
		}
	}

	if ($elasticsearch != undef)
	{
		$_elasticsearch = $elasticsearch
	}
	elsif ($_elasticsearch_server != undef and $_elasticsearch_index_name != undef)
	{
		$_elasticsearch = true
	}
	else
	{
		$_elasticsearch = false
	}

	# memcached options.
	if ($memcached_server != undef)
	{
		$_memcached_server = $memcached_server
	}
	else
	{
		if ($collect_memcached == true)
		{
			$_memcached_server = keys($memcached_servers)
		}
		else
		{
			fail("resource collection disabled for memcached, parameter required for \$memcached_server")
		}
	}

	if ($memcached_namespace != undef)
	{
		$_memcached_namespace = $memcached_namespace
	}
	else
	{
		if ($collect_memcached == true)
		{
			$memcached_namespaces = split(inline_template("<%- @memcached_servers.each do |h, v| -%><%= v[namespace] %><%- end -%>"), "\n")

			if (size($memcached_namespaces) > 1)
			{
				fail("found more than one value for \$memcached_namespace for $site_name (only one is possible): $memcached_namespaces")
			}
			elsif (size($memcached_namespaces) < 1)
			{
				fail("could not find value for \$memcached_namespace for $site_name")
			}

			$_memcached_namespace = join($memcached_namespaces, ",")
		}
		else
		{
			fail("resource collection disabled for memcached, parameter required for \$memcached_namespace")
		}
	}

	# Zebra options.
	if ($zebra_hostname != undef)
	{
		$_zebra_hostname = $zebra_hostname
	}
	else
	{
		if ($collect_zebra == true)
		{
			$_zebra_hostname = $zebra_server["hostname"]
		}
		else
		{
			fail("resource collection disabled for zebra, parameter required for \$zebra_hostname")
		}
	}

	if ($zebra_user != undef)
	{
		$_zebra_user = $zebra_user
	}
	else
	{
		if ($collect_zebra == true)
		{
			$_zebra_user = $zebra_server["user"]
		}
		else
		{
			fail("resource collection disabled for zebra, parameter required for \$zebra_user")
		}
	}

	if ($zebra_password != undef)
	{
		$_zebra_password = $zebra_password
	}
	else
	{
		if ($collect_db == true)
		{
			$_zebra_password = $zebra_server["password"]
		}
		else
		{
			fail("resource collection disabled for zebra, parameter required for \$zebra_password")
		}
	}

	##
	# Processed default parameters.
	##

	$_koha_conf_xml = pick($koha_conf_xml, "${koha_site_dir}/${site_name}/koha-conf.xml")
	$_koha_user = pick($koha_user, "$site_name-koha")

	##
	# Resource declaration.
	##

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
		memcached_server	=> $_memcached_server,
		memcached_namespace	=> $_memcached_namespace,

		require			=> [ Class["::koha"], ::Koha::User[$_koha_user] ],
		before			=> Class["::koha::service"],
		notify			=> Class["::apache::service"],
	}

	# Required folders for configuration and log files.
	file
	{ "$koha_log_dir/$site_name":
		ensure	=> $directory_ensure,
		owner	=> $_koha_user,
		group	=> $_koha_user,
		mode	=> $koha_log_dir_mode,

		require	=> [ Class["::koha"], ::Koha::User[$_koha_user] ],
		notify	=> Class["::apache::service"],
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
		elasticsearch			=> $_elasticsearch,

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

		elasticsearch_server		=> $_elasticsearch_server,
		elasticsearch_index_name	=> $_elasticsearch_index_name,

		require				=> [ Class["::koha"], ::Koha::User[$_koha_user], File["$koha_site_dir/$site_name"] ],
		before				=> Class["::apache::service"],
		subscribe			=> Class["::koha::service"],
	}
	
	# Start the Koha service, if it hasn't been already.
	include koha::service
}
