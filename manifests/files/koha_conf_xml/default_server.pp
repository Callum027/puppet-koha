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
define koha::files::koha_conf_xml::default_server
(
	$ensure				= "present",

	$site_name			= $name,
	$id,

	$listen				= true,
	$server				= true,
	$serverinfo			= true,

	# Listen options.
	$listen_socket			= undef,

	# Server options.
	$server_config			= undef,
	$server_dom_retrieval_info	= undef,
	$server_indexing_mode		= undef,
	$server_marc_format		= undef,

	$server_public_sru_server	= undef,
	$server_sru_explain		= undef,
	$server_sru_host		= undef,
	$server_sru_port		= undef,
	$server_sru_database		= undef,

	# Serverinfo options.
	$serverinfo_user		= undef,
	$serverinfo_pass		= undef,

	# koha::params default values.
	$koha_lib_dir			= $::koha::params::koha_lib_dir
)
{
	unless ($listen != true or defined(::Koha::Files::Koha_conf_xml::Listen["$site_name-$id"]))
	{
		::koha::files::koha_conf_xml::listen
		{ "$site_name-$id":
			ensure		=> $ensure,

			site_name	=> $site_name,
			id		=> $id,

			socket		=> $listen_socket,
		}
	}

	unless ($server != true or defined(::Koha::Files::Koha_conf_xml::Server["$site_name-$id"]))
	{
		::koha::files::koha_conf_xml::server
		{ "$site_name-$id":
			ensure			=> $ensure,

			site_name		=> $site_name,
			id			=> $id,

			config			=> $server_config,
			dom_retrieval_info	=> $server_dom_retrieval_info,
			indexing_mode		=> $server_indexing_mode,
			marc_format		=> $server_marc_format,

			public_sru_server	=> $server_public_sru_server,
			sru_explain		=> $server_sru_explain,
			sru_host		=> $server_sru_host,
			sru_port		=> $server_sru_port,
			sru_database		=> $server_sru_database,

			koha_lib_dir		=> $koha_lib_dir,
		}
	}

	unless ($serverinfo != true or defined(::Koha::Files::Koha_conf_xml::Serverinfo["$site_name-$id"]))
	{
		::koha::files::koha_conf_xml::serverinfo
		{ "$site_name-$id":
			ensure		=> $ensure,

			site_name	=> $site_name,
			id		=> $id,

			user		=> $serverinfo_user,
			password	=> $serverinfo_password,
		}
	}
}
