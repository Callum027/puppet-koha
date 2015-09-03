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
define koha::site::koha_conf_xml::biblioserver
(
	$ensure			= "present",
	$site_name		= $name,

	# Listen options.
	$listen_socket,

	# Server options.
	$server_indexing_mode,
	$server_marc_format,
	$server_public_sru_server,
	$server_sru_host,
	$server_sru_port,
	$server_sru_database,

	# Serverinfo options.
	$serverinfo_user,
	$serverinfo_password,
)
{
	if ($ensure == "present")
	{
		::Koha::Files::Koha_conf_xml::Biblioserver <| site_name == $site_name |>
		{
			listen_socket			=> $listen_socket,

			server_indexing_mode		=> $server_indexing_mode,
			server_marc_format		=> $server_marc_format,
			server_public_sru_server	=> $server_public_sru_server,
			server_sru_host			=> $server_sru_host,
			server_sru_port			=> $server_sru_port,
			server_sru_database		=> $server_sru_database,

			serverinfo_user			=> $serverinfo_user,
			serverinfo_password		=> $serverinfo_password,
		}
	}
}
