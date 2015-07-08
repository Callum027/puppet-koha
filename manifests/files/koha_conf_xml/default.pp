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
define koha::files::koha_conf_xml::default
(
	$ensure					= "present",
	$site_name				= $name,

	$config					= true,
	$listen					= true,
	$server					= true,
	$serverinfo				= true,
	$elasticsearch				= false,

	$biblioserver				= true,
	$authorityserver			= true,
	$publicserver				= false,
	$mergeserver				= false,

	# koha-conf.xml file options.
	$file,
	$file_owner				= $::koha::params::koha_conf_xml::file_owner,
	$file_group,
	$file_mode				= $::koha::params::koha_conf_xml::file_mode,

	# Global default options.
	$biblios_indexing_mode			= $::koha::params::koha_conf_xml::default_biblios_indexing_mode,
	$authorities_indexing_mode		= $::koha::params::koha_conf_xml::default_authorities_indexing_mode,

	# Config options.
	$config_db_scheme			= $::koha::params::koha_conf_xml::config_db_scheme,
	$config_database			= undef, # Required for config == true
	$config_hostname			= undef, # Required for config == true
	$config_port				= undef, # Defined in resource body
	$config_user				= undef, # Required for config == true
	$config_pass				= undef, # Required for config == true

	# Server options.
	$server_marc_format			= $::koha::params::koha_conf_xml::server_marc_format,

	# Serverinfo options.
	$serverinfo_user			= $::koha::params::koha_conf_xml::serverinfo_user,
	$serverinfo_password			= undef, # Required for serverinfo == true

	# Elasticsearch options.
	$elasticsearch_server			= undef, # Required for elasticsearch == true
	$elasticserach_index_name		= undef, # Required for elasticsearch == true

	# Biblioserver options.
	$biblioserver_id			= $::koha::params::koha_conf_xml::biblioserver_id,
	$biblioserver_socket			= undef, # Defined in resource body
	$biblioserver_config			= undef, # Defined in resource body
	$biblioserver_dom_retrieval_info	= undef, # Defined in resource body

	$biblioserver_public_sru_server		= false,
	$biblioserver_sru_explain		= $::koha::params::koha_conf_xml::biblioserver_sru_explain,
	$biblioserver_sru_host			= undef, # Required for biblioserver_public_sru_server == true
	$biblioserver_sru_port			= $::koha::params::koha_conf_xml::biblioserver_sru_port,
	$biblioserver_sru_database		= $::koha::params::koha_conf_xml::config_biblioserver,

	# Authorityserver options.
	$authorityserver_id			= $::koha::params::koha_conf_xml::authorityserver_id,
	$authorityserver_socket			= undef, # Defined in resource body
	$authorityserver_config			= undef, # Defined in resource body
	$authorityserver_dom_retrieval_info	= undef, # Defined in resource body

	$authorityserver_public_sru_server	= false,
	$authorityserver_sru_explain		= $::koha::params::koha_conf_xml::authorityserver_sru_explain,
	$authorityserver_sru_host		= undef, # Required for authorityserver_public_sru_server == true
	$authorityserver_sru_port		= $::koha::params::koha_conf_xml::authorityserver_sru_port,
	$authorityserver_sru_database		= $::koha::params::koha_conf_xml::config_authorityserver,

	# Publicserver options.
	$publicserver_id			= $::koha::params::koha_conf_xml::publicserver_id,
	$publicserver_socket			= $::koha::params::koha_conf_xml::publicserver_socket,
	$publicserver_config			= undef, # Defined in resource body
	$publicserver_dom_retrieval_info	= undef, # Defined in resource body

	$publicserver_sru_explain		= $::koha::params::koha_conf_xml::publicserver_sru_explain,
	$publicserver_sru_host			= undef, # Required for publicserver == true
	$publicserver_sru_port			= $::koha::params::koha_conf_xml::publicserver_sru_port,
	$publicserver_sru_database		= $::koha::params::koha_conf_xml::config_publicserver,

	# Mergeserver options.
	$mergeserver_id				= $::koha::params::koha_conf_xml::mergeserver_id,
	$mergeserver_socket			= $::koha::params::koha_conf_xml::mergeserver_socket,
	$mergeserver_config			= undef, # Defined in resource body
	$mergeserver_cql2rpn			= $::koha::params::koha_conf_xml::mergeserver_cql2rpn,

	# koha::params default values.
	$koha_lib_dir				= $::koha::params::koha_lib_dir,
	$koha_run_dir				= $::koha::params::koha_run_dir,
	$koha_site_dir				= $::koha::params::koha_site_dir,
	$koha_spool_dir				= $::koha::params::koha_spool_dir
)
{
	##
	# Set default values.
	##

	# Config options.
	if ($config_port == undef)
	{
		# Also does validation for $config_db_scheme.
		case $config_db_scheme
		{
			"mysql":	{ $_config_port = $::koha::params::koha_conf_xml::config_port_mysql }
			"postgresql":	{ $_config_port = $::koha::params::koha_conf_xml::config_port_postgresql }
			default:	{ fail("$config_db_scheme is not a valid database scheme") }
		}
	}
	else
	{
		$_config_port = $config_port
	}

	# Biblioserver options.
	if ($biblioserver_socket == undef)
	{
		if ($biblioserver_public_sru_server == true)
		{
			$_biblioserver_socket = "tcp:@:${biblioserver_sru_port}"
		}
		else
		{
			$_biblioserver_socket = "unix:${koha_run_dir}/${site_name}/bibliosocket"
		}
	}
	else
	{
		$_biblioserver_socket = $biblioserver_socket
	}

	if ($biblioserver_config == undef)
	{
		case $biblios_indexing_mode
		{
			"dom":	{ $_biblioserver_config = "${koha_site_dir}/${site_name}/zebra-biblios-dom.cfg" }
			"grs1":	{ $_biblioserver_config = "${koha_site_dir}/${site_name}/zebra-biblios.cfg" }
			default: { fail("$biblios_indexing_mode is not a valid indexing mode for bibliographic records") }
		}
	}
	else
	{
		$_biblioserver_config = $biblioserver_config
	}

	if ($biblioserver_dom_retrieval_info == undef)
	{
		$_biblioserver_dom_retrieval_info = "${koha_config_dir}/${server_marc_format}-retrieval-info-bib-dom.xml"
	}
	else
	{
		$_biblioserver_dom_retrieval_info = $biblioserver_dom_retrieval_info
	}

	# Authorityserver options.
	if ($authorityserver_socket == undef)
	{
		if ($authorityserver_public_sru_server == true)
		{
			$_authorityserver_socket = "tcp:@:${authorityserver_sru_port}"
		}
		else
		{
			$_authorityserver_socket = "unix:${koha_run_dir}/${site_name}/authoritysocket"
		}
	}
	else
	{
		$_authorityserver_socket = $authorityserver_socket
	}

	if ($authorityserver_config == undef)
	{
		case $authorities_indexing_mode
		{
			"dom":	{ $_authorityserver_config = "${koha_site_dir}/${site_name}/zebra-authorities-dom.cfg" }
			"grs1":	{ $_authorityserver_config = "${koha_site_dir}/${site_name}/zebra-authorities.cfg" }
			default: { fail("$authorities_indexing_mode is not a valid indexing mode for authority records") }
		}
	}
	else
	{
		$_authorityserver_config = $authorityserver_config
	}

	if ($authorityserver_dom_retrieval_info == undef)
	{
		$_authorityserver_dom_retrieval_info = "${koha_config_dir}/${server_marc_format}-retrieval-info-bib-dom.xml"
	}
	else
	{
		$_authorityserver_dom_retrieval_info = $authorityserver_dom_retrieval_info
	}

	# Publicserver options.
	if ($publicserver_config == undef)
	{
		$_publicserver_config = $_biblioserver_config
	}
	else
	{
		$_publicserver_config = $publicserver_config
	}

	if ($publicserver_dom_retrieval_info == undef)
	{
		$_publicserver_dom_retrieval_info = $_biblioserver_dom_retrieval_info
	}
	else
	{
		$_publicserver_dom_retrieval_info = $publicserver_dom_retrieval_info
	}

	# Mergeserver options.
	if ($mergeserver_config == undef)
	{
		$_mergeserver_config = $_biblioserver_config
	}
	else
	{
		$_mergeserver_config = $mergeserver_config
	}

	##
	# Type validation.
	##

	unless ($config != true)
	{
		# Validation for $config_db_scheme is done when $config_port is checked.
		validate_string($config_database, $config_hostname, $config_user, $config_pass)
	}

	unless ($serverinfo != true or ($biblioserver != true and $authorityserver != true and $publicserver != true))
	{
		validate_string($serverinfo_user, $serverinfo_password)
	}

	if (!is_integer($_config_port))
	{
		validate_re($_config_port, "^[:digit:]*$", "$_config_port is not a valid port number")
	}

	##
	# Config part resource declarations.
	##

	# koha-conf.xml file.
	unless (defined(::Koha::Files::Koha_conf_xml[$site_name]))
	{
		::koha::files::koha_conf_xml
		{ $site_name:
			ensure		=> $ensure,

			file		=> $file,
			owner		=> $file_owner,
			group		=> $file_group,
			mode		=> $file_mode,

			koha_site_dir	=> $koha_site_dir,
		}
	}

	# Config.
	unless (defined(::Koha::Files::Koha_conf_xml::Config[$site_name]))
	{
		::koha::files::koha_conf_xml::config
		{ $site_name:
			ensure			=> $ensure,

			db_scheme		=> $config_db_scheme,
			database		=> $_config_database,
			hostname		=> $config_hostname,
			port			=> $_config_port,
			user			=> $config_user,
			pass			=> $config_pass,			

			biblioserver		=> $koha_zebra_biblioserver,
			authorityserver		=> $koha_zebra_authorityserver,

			zebra_bib_index_mode	=> $config_zebra_bib_index_mode,
			zebra_auth_index_mode	=> $config_zebra_auth_index_mode,

			koha_config_dir		=> $koha_config_dir,
			koha_doc_dir		=> $koha_doc_dir,
			koha_lib_dir		=> $koha_lib_dir,
			koha_run_dir		=> $koha_run_dir,
			koha_share_dir		=> $koha_share_dir,
			koha_spool_dir		=> $koha_spool_dir,

			koha_lib_dir		=> $koha_lib_dir,
			koha_run_dir		=> $koha_run_dir,
			koha_spool_dir		=> $koha_spool_dir,
		}
	}

	# Elasticsearch.
	unless ($elasticsearch != true or defined(::Koha::Files::Koha_conf_xml::Elasticsearch[$site_name]))
	{
		::koha::files::koha_conf_xml::elasticsearch
		{ $site_name:
			ensure		=> $ensure,

			server		=> $elasticsearch_server,
			index_name	=> $elasticsearch_index_name,
		}
	}

	# Biblioserver.
	if ($biblioserver == true)
	{
		::koha::files::koha_conf_xml::default_server
		{ "$site_name-$biblioserver_id":
			ensure				=> $ensure,

			site_name			=> $site_name,
			id				=> $biblioserver_id,

			listen_socket			=> $_biblioserver_socket,

			server_config			=> $_biblioserver_config,
			server_dom_retrieval_info	=> $_biblioserver_dom_retrieval_info,
			server_indexing_mode		=> $biblios_indexing_mode,
			server_marc_format		=> $server_marc_format,

			server_public_sru_server	=> $biblioserver_public_sru_server,
			server_sru_explain		=> $biblioserver_sru_explain,
			server_sru_host			=> $biblioserver_sru_host,
			server_sru_port			=> $biblioserver_sru_port,
			server_sru_database		=> $biblioserver_sru_database,

			serverinfo_user			=> $serverinfo_user,
			serverinfo_password		=> $serverinfo_password,

			koha_lib_dir			=> $koha_lib_dir,
		}
	}

	# Authorityserver.
	if ($authorityserver == true)
	{
		::koha::files::koha_conf_xml::default_server
		{ "$site_name-$authorityserver_id":
			ensure				=> $ensure,

			site_name			=> $site_name,
			id				=> $authorityserver_id,

			listen_socket			=> $_authorityserver_socket,

			server_config			=> $_authorityserver_config,
			server_dom_retrieval_info	=> $_authorityserver_dom_retrieval_info,
			server_indexing_mode		=> $authorities_indexing_mode,
			server_marc_format		=> $server_marc_format,

			server_public_sru_server	=> $authorityserver_public_sru_server,
			server_sru_explain		=> $authorityserver_sru_explain,
			server_sru_host			=> $authorityserver_sru_host,
			server_sru_port			=> $authorityserver_sru_port,
			server_sru_database		=> $authorityserver_sru_database,

			serverinfo_user			=> $serverinfo_user,
			serverinfo_password		=> $serverinfo_password,

			koha_lib_dir			=> $koha_lib_dir,
		}
	}

	# Publicserver.
	if ($publicserver == true)
	{
		::koha::files::koha_conf_xml::default_server
		{ "$site_name-$publicserver_id":
			ensure				=> $ensure,

			site_name			=> $site_name,
			id				=> $publicserver_id,

			listen_socket			=> $_publicserver_socket,

			server_config			=> $_publicserver_config,
			server_dom_retrieval_info	=> $_publicserver_dom_retrieval_info,
			server_indexing_mode		=> $biblios_indexing_mode,
			server_marc_format		=> $server_marc_format,

			server_public_sru_server	=> true,
			server_sru_explain		=> $publicserver_sru_explain,
			server_sru_host			=> $publicserver_sru_host,
			server_sru_port			=> $publicserver_sru_port,
			server_sru_database		=> $publicserver_sru_database,

			serverinfo_user			=> $serverinfo_user,
			serverinfo_password		=> $serverinfo_password,

			koha_lib_dir			=> $koha_lib_dir,
		}
	}

	# Mergeserver.
	if ($mergeserver == true)
	{
		::koha::files::koha_conf_xml::default_server
		{ "$site_name-$mergeserver_id":
			ensure				=> $ensure,

			site_name			=> $site_name,
			id				=> $mergeserver_id,

			serverinfo			=> false,

			listen_socket			=> $mergeserver_socket,

			server_config			=> $_mergeserver_config,
			server_cql2rpn			=> $mergeserver_cql2rpn,
			server_include_retrieval_info	=> false,

			koha_lib_dir			=> $koha_lib_dir,
		}
	}

}