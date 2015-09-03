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
define koha::files::koha_conf_xml::koha_site
(
	$ensure			= "present",
	$site_name		= $name,

	$collect_db		= true,
	$collect_zebra		= true,
	$collect_elasticsearch	= false
)
{
	unless (defined(::Koha::Files::Koha_conf_xml[$site_name]))
	{
		::koha::files::koha_conf_xml
		{ $site_name:
			ensure	=> $ensure,
		}
	}

	unless (defined(::Koha::Files::Koha_conf_xml::Config[$site_name]))
	{
		::koha::files::koha_conf_xml::config
		{ $site_name:
			ensure	=> $ensure,
		}
	}

	if ($ensure == "present" and $collect_db == true)
	{
		::Koha::Site::Db <<| site_name == $site_name |>>
	}

	unless (defined(::Koha::Files::Koha_conf_xml::Zebra_site[$site_name]))
	{
		if ($ensure == "present" and $collect_zebra == true)
		{
			::Koha::Site::Zebra <<| site_name == $site_name |>>
		}
	}

	if ($ensure == "present" and $collect_elasticsearch == true)
	{
		::Koha::Site::Elasticsearch <<| site_name == $site_name |>>
	}
}
