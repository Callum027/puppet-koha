# == Class: koha::mysql::site
#
# Add a Koha MySQL database for the given site name.
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
define koha::site::elasticsearch
(
	$ensure			= "present",
	$site_name,

	$server,
	$index_name
)
{
	if ($ensure == "present")
	{
		::Koha::Files::Koha_conf_xml::Default <| site_name == $site_name |>
		{
			elasticsearch			=> true,
			elasticsearch_index_name	=> $index_name,
		}
	}

	::koha::files::koha_conf_xml::elasticsearch_server
	{ "$index_name-$server":
		ensure		=> $ensure,
		server		=> $server,
		index_name	=> $index_name,
	}
}
