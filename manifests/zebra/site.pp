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
define koha::zebra::site
(
	$ensure						= "present",
	$site_name					= $name,

	# Zebra options meant to be set by the user.
	$user						= "kohauser",
	$password,

	$language					= $::koha::params::koha_language,
	$marc_format					= "marc21",
	$indexing_mode					= "dom",

	# Global (both biblioserver and authorityserver) SRU server options.
	$public_sru_server				= false,
	$sru_host					= undef,
	$sru_port					= undef,

	# Global koha-conf.xml options.
	$server_cql2rpn					= undef, # Defined in resource body
	$serverinfo_ccl2rpn				= undef, # Defined in resource body

	##
	# Biblioserver options.
	##
	$biblioserver					= true,

	# Listen options.
	$biblioserver_listen_socket			= undef, # Default set in ::koha::zebra::site::server
	# Variables used to determine the above.
	$biblioserver_listen_scheme			= "unix",
	$biblioserver_listen_unix_socket		= "bibliosocket",
	$biblioserver_listen_tcp_port			= "9998",

	# Server options.
	$biblioserver_server_directory			= undef, # Defined in resource body
	$biblioserver_server_config			= undef, # Default set in ::koha::zebra::site::server
	# Start variables used to determine $biblioserver_server_config.
	$biblioserver_server_config_grs1		= undef, # Defined in resource body
	$biblioserver_server_config_dom			= undef, # Defined in resource body
	# End.
	$biblioserver_server_cql2rpn			= undef, # Defined in resource body
	$biblioserver_server_retrieval_config		= undef, # Defined in resource body
	$biblioserver_server_enable_sru			= false,
	$biblioserver_server_sru_explain		= undef, # Defined in resource body
	$biblioserver_server_sru_host			= $::fqdn,
	$biblioserver_server_sru_port			= undef,
	$biblioserver_server_sru_database		= "biblioserver",

	# Serverinfo options.
	$biblioserver_serverinfo_ccl2rpn		= undef, # Defined in resource body

	##
	# Authorityserver options.
	##
	$authorityserver				= true,

	# Listen options.
	$authorityserver_listen_socket			= undef, # Default set in ::koha::zebra::site::server
	# Variables used to determine the above.
	$authorityserver_listen_scheme			= "unix",
	$authorityserver_listen_unix_socket		= "authoritysocket",
	$authorityserver_listen_tcp_port		= "9999",

	# Server options.
	$authorityserver_server_directory		= undef, # Defined in resource body
	$authorityserver_server_config			= undef, # Default set in ::koha::zebra::site::server
	# Start variables used to determine $authorityserver_server_config.
	$authorityserver_server_config_grs1		= undef, # Defined in resource body
	$authorityserver_server_config_dom		= undef, # Defined in resource body
	# End.
	$authorityserver_server_cql2rpn			= undef, # Defined in resource body
	$authorityserver_server_retrieval_config	= undef, # Defined in resource body
	$authorityserver_server_enable_sru		= false,
	$authorityserver_server_sru_explain		= undef, # Defined in resource body
	$authorityserver_server_sru_host		= $::fqdn,
	$authorityserver_server_sru_port		= undef,
	$authorityserver_server_sru_database		= "authorityserver",

	# Serverinfo options.
	$authorityserver_serverinfo_ccl2rpn		= undef, # Defined in resource body

	##
	# koha::params default values.
	##
	$koha_config_dir				= $::koha::params::koha_config_dir,
	$koha_lib_dir					= $::koha::params::koha_lib_dir,
	$koha_site_dir					= $::koha::params::koha_site_dir,
	$koha_site_dir_conf_file_owner			= $::koha::params::koha_site_dir_conf_file_owner,
	$koha_site_dir_conf_file_mode			= $::koha::params::koha_site_dir_conf_file_mode,
	$koha_site_dir_passwd_file_mode			= $::koha::params::koha_site_dir_passwd_file_mode
)
{
	##
	# Post-definition variable declarations.
	##
	$koha_user = getparam(::Koha::User_name[$site_name], "user")

	# Global koha-conf.xml options.
	$_server_cql2rpn = pick($server_cql2rpn, "${koha_config_dir}/zebradb/pqf.properties")
	$_serverinfo_ccl2rpn = pick($serverinfo_ccl2rpn, "${koha_config_dir}/zebradb/ccl.properties")

	# Biblioserver options.
	$_biblioserver_server_directory = pick($biblioserver_server_directory, "${koha_lib_dir}/${site_name}/biblios")
	$_biblioserver_server_config_grs1 = pick($biblioserver_server_config_grs1, "${koha_site_dir}/${site_name}/zebra-biblios.cfg")
	$_biblioserver_server_config_dom = pick($biblioserver_server_config_dom, "${koha_site_dir}/${site_name}/zebra-biblios-dom.cfg")
	$_biblioserver_server_cql2rpn = pick($biblioserver_server_cql2rpn, $_server_cql2rpn)
	$_biblioserver_server_retrieval_config = pick($biblioserver_server_retieval_config, "$koha_config_dir/${marc_format}-retrieval-info-bib-dom.xml")
	$_biblioserver_server_sru_explain = pick($biblioserver_server_sru_explain, "$koha_config_dir/explain-biblios.xml")
	$_biblioserver_serverinfo_ccl2rpn = pick($biblioserver_serverinfo_ccl2rpn, $_serverinfo_ccl2rpn)

	# Biblioserver options.
	$_authorityserver_server_directory = pick($authorityserver_server_directory, "$koha_lib_dir/${site_name}/authorities")
	$_authorityserver_server_config_grs1 = pick($authorityserver_server_config_grs1, "$koha_site_dir/${site_name}/zebra-authorities.cfg")
	$_authorityserver_server_config_dom = pick($authorityserver_server_config_dom, "$koha_site_dir/${site_name}/zebra-authoritiess-dom.cfg")
	$_authorityserver_server_cql2rpn = pick($authorityserver_server_cql2rpn, $_server_cql2rpn)
	$_authorityserver_server_retrieval_config = pick($authorityserver_server_retieval_config, "$koha_config_dir/${marc_format}-retrieval-info-auth-dom.xml")
	$_authorityserver_server_sru_explain = pick($authorityserver_server_sru_explain, "$koha_config_dir/explain-authorities.xml")
	$_authorityserver_serverinfo_ccl2rpn = pick($authorityserver_serverinfo_ccl2rpn, $_serverinfo_ccl2rpn)

	##
	# Files required by the Zebra server instance.
	##
	unless (defined(::Koha::Site_resources[$site_name]))
	{
		::koha::site_resources
		{ $site_name:
			ensure	=> $ensure,
		}
	}

	file
	{ "$koha_site_dir/$site_name/zebra.passwd":
		ensure	=> $ensure,
		owner	=> $koha_site_dir_conf_file_owner,
		group	=> $koha_user,
		mode	=> $koha_site_dir_passwd_file_mode,
		content	=> template("koha/zebra.passwd.erb"),
		require	=> [ Class["::koha::zebra::install"], ::Koha::Site_resources[$site_name] ],
		notify	=> Class["::koha::zebra::service"],
	}

	# Required configuration files for the Zebra index.
	file
	{ $_biblioserver_server_config_grs1:
		ensure	=> $ensure,
		owner	=> $koha_site_dir_conf_file_owner,
		group	=> $koha_user,
		mode	=> $koha_site_dir_conf_file_mode,
		content	=> template("koha/zebra-biblios-site.cfg.erb"),
		require	=> [ Class["::koha::zebra"], ::Koha::Site_resources[$site_name] ],
		notify	=> Class["::koha::zebra::service"],
	}

	file
	{ $_biblioserver_server_config_dom:
		ensure	=> $ensure,
		owner	=> $koha_site_dir_conf_file_owner,
		group	=> $koha_user,
		mode	=> $koha_site_dir_conf_file_mode,
		content	=> template("koha/zebra-biblios-dom-site.cfg.erb"),
		require	=> [ Class["::koha::zebra"], ::Koha::Site_resources[$site_name] ],
		notify	=> Class["::koha::zebra::service"],
	}

	file
	{ $_authorityserver_server_config_grs1:
		ensure	=> $ensure,
		owner	=> $koha_site_dir_conf_file_owner,
		group	=> $koha_user,
		mode	=> $koha_site_dir_conf_file_mode,
		content	=> template("koha/zebra-authorities-site.cfg.erb"),
		require	=> [ Class["::koha::zebra"], ::Koha::Site_resources[$site_name] ],
		notify	=> Class["::koha::zebra::service"],
	}

	file
	{ $_authorityserver_server_config_dom:
		ensure	=> $ensure,
		owner	=> $koha_site_dir_conf_file_owner,
		group	=> $koha_user,
		mode	=> $koha_site_dir_conf_file_mode,
		content	=> template("koha/zebra-authorities-dom-site.cfg.erb"),
		require	=> [ Class["::koha::zebra"], ::Koha::Site_resources[$site_name] ],
		notify	=> Class["::koha::zebra::service"],
	}

	##
	# koha-conf.xml configuration of the Zebra client and server.
	##
	if (defined(::Koha::Files::Koha_conf_xml[$site_name]))
	{
		Class["::koha::zebra::install"] -> ::Koha::Files::Koha_conf_xml[$site_name]
	}
	else
	{
		::koha::files::koha_conf_xml
		{ $site_name:
			ensure	=> $ensure,
			require	=> Class["::koha::zebra::install"],
		}
	}

	unless (defined(::Koha::Files::Koha_conf_xml::Config[$site_name]))
	{
		::koha::files::koha_conf_xml::config
		{ $site_name:
			ensure			=> $ensure,
			zebra_bib_index_mode	=> $indexing_mode,
			zebra_auth_index_mode	=> $indexing_mode,
		}
	}

	if ($biblioserver == true)
	{
		::koha::zebra::site::client
		{ "$site_name-biblioserver":
			# TODO: what does a Zebra client need to be configured with?
		}

		::koha::zebra::site::server
		{ "$site_name-biblioserver":
			site_name			=> $site_name,
			id				=> "biblioserver",

			listen_socket			=> $biblioserver_listen_socket,
			listen_scheme			=> $biblioserver_listen_scheme,
			listen_unix_socket		=> $biblioserver_listen_unix_socket,
			listen_tcp_port			=> $biblioserver_listen_tcp_port,

			server_indexing_mode		=> $indexing_mode,
			server_marc_format		=> $marc_format,
			server_directory		=> $_biblioserver_server_directory,
			server_config			=> $_biblioserver_server_config,
			server_config_grs1		=> $_biblioserver_server_config_grs1,
			server_config_dom		=> $_biblioserver_server_config_dom,
			server_cql2rpn			=> $_biblioserver_server_cql2rpn,
			server_retrieval_config		=> $_biblioserver_server_retrieval_config,
			server_enable_sru		=> $biblioserver_server_enable_sru,
			server_sru_explain		=> $_biblioserver_server_sru_explain,
			server_sru_host			=> $biblioserver_server_sru_host,
			server_sru_port			=> $biblioserver_server_sru_port,
			server_sru_database		=> $biblioserver_server_sru_database,

			serverinfo_ccl2rpn		=> $_biblioserver_serverinfo_ccl2rpn,
			serverinfo_user			=> $user,
			serverinfo_password		=> $password,
		}
	}

	if ($authorityserver == true)
	{
		::koha::zebra::site::client
		{ "$site_name-authorityserver":
			# TODO: what does a Zebra client need to be configured with?
		}

		::koha::zebra::site::server
		{ "$site_name-authorityserver":
			site_name			=> $site_name,
			id				=> "authorityserver",

			listen_socket			=> $authorityserver_listen_socket,
			listen_scheme			=> $authorityserver_listen_scheme,
			listen_unix_socket		=> $authorityserver_listen_unix_socket,
			listen_tcp_port			=> $authorityserver_listen_tcp_port,

			server_indexing_mode		=> $indexing_mode,
			server_marc_format		=> $marc_format,
			server_directory		=> $_authorityserver_server_directory,
			server_config			=> $_authorityserver_server_config,
			server_config_grs1		=> $_authorityserver_server_config_grs1,
			server_config_dom		=> $_authorityserver_server_config_dom,
			server_cql2rpn			=> $_authorityserver_server_cql2rpn,
			server_retrieval_config		=> $_authorityserver_server_retrieval_config,
			server_enable_sru		=> $authorityserver_server_enable_sru,
			server_sru_explain		=> $_authorityserver_server_sru_explain,
			server_sru_host			=> $authorityserver_server_sru_host,
			server_sru_port			=> $authorityserver_server_sru_port,
			server_sru_database		=> $authorityserver_server_sru_database,

			serverinfo_ccl2rpn		=> $_authorityserver_serverinfo_ccl2rpn,
			serverinfo_user			=> $user,
			serverinfo_password		=> $password,
		}
	}
}
