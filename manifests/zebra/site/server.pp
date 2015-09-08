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
define koha::zebra::site::server
(
	$ensure				= "present",
	$site_name,
	$id,

	# Zebra options meant to be set by the user.

	$listen_socket			= undef, # Defined in resource body
	# Variables used to determine the above.
	$listen_scheme,
	$listen_unix_socket,
	$listen_tcp_port,

	$server_indexing_mode,
	$server_marc_format,
	$server_directory,
	$server_config			= undef, # Defined in resource body
	# Start variables used to determine $server_config.
	$server_config_grs1,
	$server_config_dom,
	# End.
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
	case $listen_scheme
	{
		"unix": { $_listen_socket = pick($listen_socket, "unix:$koha_run_dir/$listen_unix_socket") }
		"tcp": { $_listen_socket = pick($listen_socket, "tcp:@:$listen_tcp_port") }
		default: { fail("invalid listen scheme 'listen_scheme' for '$id', valid values are 'unix' and 'tcp'") }
	}

	case $server_indexing_mode
	{
		"grs1": { $_server_config = pick($server_config, $server_config_grs1) }
		"dom": { $_server_config = pick($server_config, $server_config_dom) }
		default: { fail("invalid indexing mode '$server_indexing_mode' for '$id', valid values are 'dom' and 'grs1'") }
	}

	::koha::site::zebra
	{ $name:
		ensure			=> $ensure,
		site_name		=> $site_name,
		id			=> $id,

		listen			=> true,
		server			=> true,
		serverinfo		=> true,

		listen_socket		=> $_listen_socket,

		server_indexing_mode	=> $server_indexing_mode,
		server_marc_format	=> $server_marc_format,
		server_directory	=> $server_directory,
		server_config		=> $_server_config,
		server_cql2rpn		=> $server_cql2rpn,
		server_retrieval_config	=> $server_retrieval_config,
		server_enable_sru	=> $server_enable_sru,
		server_sru_explain	=> $server_sru_explain,
		server_sru_host		=> $server_sru_host,
		server_sru_port		=> $server_sru_port,
		server_sru_database	=> $server_sru_database,

		serverinfo_ccl2rpn	=> $serverinfo_ccl2rpn,
		serverinfo_user		=> $serverinfo_user,
		serverinfo_password	=> $serverinfo_password,
	}
}
