# == Class: koha::zebra::site
#
# Add a site to the Zebra indexer.
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
define koha::site::zebra
(
	$ensure			= "present",
	$site_name,
	$id,

	$listen,
	$server,
	$serverinfo,

	$listen_socket,
	# Variables used to determine the above.
	$listen_scheme,
	$listen_unix_socket,
	$listen_tcp_port,

	$server_indexing_mode,
	$server_marc_format,
	$server_directory,
	$server_config,
	$server_cql2rpn,
	$server_retrieval_config,
	$server_enable_sru,
	$server_sru_explain,
	$server_sru_host,
	$server_sru_port,
	$server_sru_database,

	$serverinfo_ccl2rpn,
	$serverinfo_user,
	$serverinfo_password,
)
{
	if ($listen == true)
	{
		::koha::files::koha_conf_xml::listen
		{ $name:
			ensure		=> $ensure,
			site_name	=> $site_name,
			id		=> $id,

			socket		=> $listen_socket,
		}
	}

	if ($server == true)
	{
		::koha::files::koha_conf_xml::server
		{ $name:
			ensure			=> $ensure,
			site_name		=> $site_name,
			id			=> $id,

			indexing_mode		=> $server_indexing_mode,
			marc_format		=> $server_marc_format,
			directory		=> $server_directory,
			config			=> $server_config,
			cql2rpn			=> $server_cql2rpn,
			retrieval_config	=> $server_retrieval_config,
			enable_sru		=> $server_enable_sru,
			sru_explain		=> $server_sru_explain,
			sru_host		=> $server_sru_host,
			sru_port		=> $server_sru_port,
			sru_database		=> $server_sru_database,
		}
	}

	if ($serverinfo == true)
	{
		::koha::files::koha_conf_xml::serverinfo
		{ $name:
			ensure		=> $ensure,
			site_name	=> $site_name,
			id		=> $id,

			ccl2rpn		=> $serverinfo_ccl2rpn,
			user		=> $serverinfo_user,
			password	=> $serverinfo_password,
		}
	}
}
