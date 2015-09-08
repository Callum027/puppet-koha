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

	$collect_db			= true,
	$collect_zebra			= true,
	$collect_memcached		= true,
	$collect_elasticsearch		= false
)
{
	##
	# Dependent resources.
	##

	unless (defined(::Koha::Site_resources[$site_name]))
	{
		::koha::site_resources
		{ $site_name:
			ensure	=> $ensure,
		}
	}

	##
	# Local Koha resources.
	##

	# koha-conf.xml configuration file.
	Class["::koha::install"] -> ::Koha::Files::Koha_conf_xml[$site_name]

	unless (defined(::Koha::Files::Koha_conf_xml[$site_name]))
	{
		::koha::files::koha_conf_xml
		{ $site_name:
			ensure	=> $ensure,
		}
	}

	unless (defined(::Koha::Files::Koha_conf_xml::Config[$site_name]))
	{
		@::koha::files::koha_conf_xml::config
		{ $site_name:
			ensure		=> $ensure,
			site_name	=> $site_name,
		}
	}

	# Apache HTTP Server.
	if (defined(::Koha::Apache::Site[$site_name]))
	{
		Class["::koha::install"] -> ::Koha::Apache::Site[$site_name]
	}
	{
		# Apache vhost for the Koha site.
		::koha::apache::site
		{ $site_name:
			ensure	=> $ensure,
			require	=> Class["::koha::install"],
		}
	}

	##
	# Collected resources.
	##

	# Database (MySQL, PostgreSQL).
	if ($collect_db == true)
	{
		::Koha::Site::Db <<| site_name == $site_name |>>
	}
	elsif (defined(::Koha::Site::Db[$site_name]) != true)
	{
		# to be defined manually because of a password requirement
		fail("required site configuration resource ::koha::site::db not defined for site '$site_name'")
	}

	# Zebra indexing system.
	unless ($collect_elasticsearch == true or defined(::Koha::Site::Elasticsearch[$site_name]))
	{
		if ($collect_zebra == true)
		{
			::Koha::Site::Zebra <<| site_name == $site_name |>>
		}
		elsif (defined(::Koha::Site::Zebra[$site_name]) != true)
		{
			# to be defined manually because of a password requirement
			fail("required site configuration resource ::koha::site::zebra not defined for site '$site_name'")
		}
	}

	# memcached.
	if ($collect_memcached == true)
	{
		::Koha::Site::Memcached <<| site_name == $site_name |>>
	}
	# memcached support is optional, don't check if defined

	# ElasticSearch.
	if ($collect_elasticsearch == true)
	{
		::Koha::Site::Elasticsearch <<| site_name == $site_name |>>
	}
	# elasticsearch support is optional, don't check if defined
}
