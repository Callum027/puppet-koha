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
	$collect_zebra			= $::koha::params::site_collect_zebra
)
{
	##
	# Collect and/or configure the servers for each component, as well as ensure external
	# resources for this server are available.
	##

	# Apache HTTP Server.
	::Koha::Site::System_resources[$site_name] -> Class["::koha::service"] ~> Class["::apache::service"]

	unless (defined(::Koha::Apache::Site[$site_name]))
	{
		# Apache vhost for the Koha site.
		::koha::apache::site
		{ $site_name:
			ensure		=> $ensure,
		}
	}

	# Database (MySQL, PostgreSQL).
	if ($collect_db == true)
	{
		::Koha::Site::Db <<| site_name == $site_name |>>
	}
	elsif (!defined(::Koha::Site::Db[$site_name]))
	{
		# to be defined manually because of a password requirement
		fail("required site configuration resource koha::site::db not defined for site '$site_name'")
	}

	# ElasticSearch.
	if ($collect_elasticsearch == true)
	{
		::Koha::Site::Elasticsearch <<| site_name == $site_name |>>
	}
	# elasticsearch support is optional, don't check if defined

	# koha-conf.xml configuration file.
	Class["::koha"] -> ::Koha::Files::Koha_conf_xml[$site_name]
	::Koha::Site::System_resources[$site_name] -> ::Koha::Files::Koha_conf_xml[$site_name]
	::Koha::Files::Koha_conf_xml[$site_name] -> Class["::apache::service"]
	::Koha::Files::Koha_conf_xml[$site_name] ~> Class["::koha::service"]

	unless (defined(::Koha::Files::Koha_conf_xml[$site_name]))
	{
		::koha::files::koha_conf_xml::default
		{ $site_name:
			ensure	=> $ensure,
		}
	}

	# memcached.
	if ($collect_memcached == true)
	{
		::Koha::Site::Memcached <<| site_name == $site_name |>>
	}
	# memcached support is optional, don't check if defined

	# System resources that are required by other classes.
	unless (defined(::Koha::Site::System_resources[$site_name]))
	{
		::koha::site::system_resources
		{ $site_name:
			ensure	=> $ensure,
		}
	}

	# Zebra indexing system.
	if ($collect_zebra == true)
	{
		::Koha::Site::Zebra <<| site_name == $site_name |>>
	}
	elsif (!defined(::Koha::Site::Zebra[$site_name]))
	{
		# to be defined manually because of a password requirement
		fail("required site configuration resource koha::site::zebra not defined for site '$site_name'")
	}
	
	# Start the Koha service, if it hasn't been already.
	if ($ensure == "present")
	{
		$service_ensure = "running"
	}
	elsif ($ensure == "absent")
	{
		$service_ensure	= "stopped"
	}
	else
	{
		$service_ensure = $ensure
	}

	unless (defined(Class["::koha::service"]))
	{
		class
		{ "koha::service":
			ensure	=> $service_ensure,
		}
	}
}
