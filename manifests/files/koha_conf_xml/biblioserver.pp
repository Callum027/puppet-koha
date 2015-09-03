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
define koha::files::koha_conf_xml::biblioserver
(
	$ensure			= "present",

	$site_name			= $name,
	$id				= "biblioserver",

	# Listen options.
	$listen_socket			= undef, # Filled in by koha::site::koha_conf_xml::biblioserver

	# Server options.
	$server_directory		= undef, # Default defined in koha::files::koha_conf_xml::server
	$server_config			= undef, # Defined in resource body
	$server_cql2rpn			= undef, # Default defined in koha::files::koha_conf_xml::server

	$server_include_retrieval_info	= undef, # Default defined in koha::files::koha_conf_xml::server

	$server_dom_retrieval_info	= undef, # Defined in resource body

	# Default defined in koha::files::koha_conf_xml::server
	$server_indexing_mode		= undef, # Filled in by koha::site::koha_conf_xml::biblioserver
	$server_marc_format		= undef, # Filled in by koha::site::koha_conf_xml::biblioserver

	$server_public_sru_server	= undef, # Filled in by koha::site::koha_conf_xml::biblioserver

	$server_sru_explain		= undef, # Defined in resource body
	$server_sru_host		= undef, # Filled in by koha::site::koha_conf_xml::biblioserver
	$server_sru_port		= undef, # Filled in by koha::site::koha_conf_xml::biblioserver
	$server_sru_database		= undef, # Filled in by koha::site::koha_conf_xml::biblioserver

	# Serverinfo options.
	$serverinfo_user		= undef, # Filled in by koha::site::koha_conf_xml::biblioserver
	$serverinfo_password		= undef, # Filled in by koha::site::koha_conf_xml::biblioserver

	# koha::params default values.
	$koha_config_dir		= $::koha::params::koha_config_dir,
	$koha_lib_dir			= $::koha::params::koha_lib_dir,
	$koha_site_dir			= $::koha::params::koha_site_dir
)
{
	##
	# Default configuration values.
	##
	case $server_indexing_mode
	{
		"dom":	{ $_server_config = "${koha_site_dir}/${site_name}/zebra-biblios-dom.cfg" }
		"grs1":	{ $_server_config = "${koha_site_dir}/${site_name}/zebra-biblios.cfg" }
		default: { fail("invalid indexing mode for bibliographic records '$indexing_mode'") }
	}

	$_server_dom_retrieval_info = pick($server_dom_retrieval_info, "${koha_config_dir}/${marc_format}-retrieval-info-bib-dom.xml")
	$_server_sru_explain = pick($server_sru_explain, "${koha_config_dir}/zebradb/explain-biblios.xml")

	##
	# Parameter validation.
	##
	if ($ensure != "present" and $ensure != "absent")
	{
		fail("Only possible values for \$ensure are 'present' and 'absent'")
	}

	##
	# Defined resources.
	##
	::koha::files::koha_conf_xml::listen
	{ "$site_name-$id":
		site_name	=> $site_name,
		id		=> $id,

		socket		=> $listen_socket,
	}

	::koha::files::koha_conf_xml::server
	{ "$site_name-$id":
		site_name		=> $site_name,
		id			=> $id,

		directory		=> $server_directory,
		config			=> $_server_config,
		cql2rpn			=> $server_cql2rpn,

		include_retrieval_info	=> $server_include_retrieval_info,

		dom_retrieval_info	=> $_server_dom_retrieval_info,

		indexing_mode		=> $server_indexing_mode,
		marc_format		=> $server_marc_format,

		public_sru_server	=> $server_public_sru_server,

		sru_explain		=> $_server_sru_explain,
		sru_host		=> $server_sru_host,
		sru_port		=> $server_sru_port,
		sru_database		=> $server_sru_database,
	}

	::koha::files::koha_conf_xml::serverinfo
	{ "$site_name-$id":
		site_name	=> $site_name,
		id		=> $id,

		user		=> $serverinfo_user,
		password	=> $serverinfo_password,
	}
}
