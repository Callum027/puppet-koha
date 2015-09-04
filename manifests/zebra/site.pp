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

	$koha_user					= undef, # Defined in resource body

	# Zebra options meant to be set by the user.
	$user						= "kohauser",
	$password,

	$language					= $::koha::params::language,
	$marc_format					= $::koha::params::marc_format,

	# Global (both biblioserver and authorityserver) SRU server options.
	$public_sru_server				= false,
	$sru_host					= undef,
	$sru_port					= undef,

	# Biblioserver options.
	$biblioserver					= true,

	$biblioserver_listen_socket			= undef, # Defined in resource body
	# Variables used to determine the above. Not put in koha-conf.xml.
	$biblioserver_listen_scheme			= "unix",
	$biblioserver_listen_port			= "9998",

	$biblioserver_server_directory			= undef, # Defined in resource body
	$biblioserver_server_sru_database		= "biblioserver",

	# Authorityserver options.
	$authorityserver				= true,

	$authorityserver_listen_socket			= undef, # Defined in resource body
	$authorityserver_server_public_sru_server	= false,
	$authorityserver_server_sru_host		= $::fqdn,
	$authorityserver_server_sru_port		= "9999",
	$authorityserver_server_sru_database		= "authorityserver",

	# koha::params default values.
	$koha_log_dir					= $::koha::params::koha_log_dir,
	$koha_log_dir_mode				= $::koha::params::koha_log_dir_mode,
	$koha_site_dir					= $::koha::params::koha_site_dir,
	$koha_site_dir_mode				= $::koha::params::koha_site_dir_mode,
	$koha_site_dir_conf_file_owner			= $::koha::params::koha_site_dir_conf_file_owner,
	$koha_site_dir_conf_file_mode			= $::koha::params::koha_site_dir_conf_file_mode
)
{

	# koha-conf.xml configuration for a Zebra server.
	if ($biblioserver == true)
	{
		# TODO: hierarchy
		# ::koha::zebra::site -> ::koha::zebra::site::server |-> ::koha::site::koha_conf_xml::server -> ::koha::koha_conf_xml::server
		#                                                    |-> ::koha::site::koha_conf_xml::serverinfo  -> ::koha::koha_conf_xml::serverinfo
		#                                                    |-> ::koha::site::koha_conf_xml::listen -> ::koha::koha_conf_xml::listen

		$_biblioserver_server_directory = pick($biblioserver_server_directory, "$koha_lib_dir/$site_name/biblios")

		case $listen_scheme
		{
			"grs1": { $_biblioserver_server_config = pick($biblioserver_server_config, "$koha_site_dir/$site_name/zebra-biblios.cfg") }
			"dom": { $_biblioserver_server_config = pick($biblioserver_server_config, "$koha_site_dir/$site_name/zebra-biblios-dom.cfg") }
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
			server_retrieval_config		=> $_biblioserver_server_retrieval_config,
			server_explain			=> $_biblioserver_server_explain,
			server_enable_sru		=> $biblioserver_server_enable_sru,
			server_sru_host			=> $biblioserver_server_sru_host,
			server_sru_port			=> $biblioserver_server_sru_port,
			server_sru_database		=> $biblioserver_server_sru_database,

			serverinfo_user			=> $user,
			serverinfo_password		=> $password,
		}
	}

	# unless (defined(Class["::koha::zebra"]))
	# {
		# fail("You must include the Koha Zebra base class before setting up a Koha Zebra site index")
	# }

	# # Set up the Koha Zebra service if it hasn't already.
	# unless (defined(Class["::koha::zebra::service"]))
	# {
		# include ::koha::zebra::service
	# }

	# $_koha_conf_xml = pick($koha_conf_xml, "${koha_site_dir}/${site_name}/koha-conf.xml")
	# $_koha_user = pick($koha_user, "$site_name-koha")

	# $_biblioserver_sru_host = pick($biblioserver_sru_host, "$site_name.$::domain")
	# $_authorityserver_sru_host = pick($authorityserver_sru_host, "$site_name.$::domain")


	# if ($ensure == "present")
	# {
		# $directory_ensure = "directory"
	# }
	# else
	# {
		# $directory_ensure = $ensure
	# }

	# # Generate the Koha user, and the log directory. But only if they
	# # haven't been defined before. They also get defined in ::koha::site.
	# if (defined(::Koha::User[$_koha_user]))
	# {
		# ::Koha::User[$_koha_user] ~> Class["::koha::zebra::service"]
	# }
	# else
	# {
		# ::koha::user
		# { $_koha_user:
			# notify	=> Class["::koha::zebra::service"],
		# }
	# }

	# if (defined(::Koha::Log_dir[$site_name]))
	# {
		# Class["::koha::zebra"] -> ::Koha::Log_dir[$site_name] ~> Class["::koha::zebra::service"]
	# }
	# else
	# {
		# ::koha::log_dir
		# { $site_name:
			# koha_user	=> $_koha_user,
			# require		=> Class["::koha::zebra"],
			# notify		=> Class["::koha::zebra::service"],
		# }
	# }

	# # Generate and install Zebra config files.
	# if (defined(File["$koha_site_dir/$site_name"]))
	# {
		# Class["::koha::zebra"] -> File["$koha_site_dir/$site_name"] ~> Class["::koha::zebra::service"]
	# }
	# else
	# {
		# file
		# { "$koha_site_dir/$site_name":
			# ensure	=> $directory_ensure,
			# owner	=> $_koha_user,
			# group	=> $_koha_user,
			# mode	=> 755,
			# require	=> [ Class["::koha::zebra"], ::Koha::User[$_koha_user] ],
			# notify	=> Class["::koha::zebra::service"],
		# }
	# }

	# # Define the default koha-conf.xml resource with Zebra-centric options, if it has not been defined already.
	# unless (defined(::Koha::Files::Koha_conf_xml::Default[$site_name]))
	# {
		# ::koha::files::koha_conf_xml::default
		# { $site_name:
			# file		=> $_koha_conf_xml,
			# file_group	=> $_koha_user,

			# config		=> false,
		# }
	# }

	# # Establish the relationship between the Zebra package installation, koha-conf.xml
	# # and the Zebra service.
	# Class["::koha::zebra"] -> ::Koha::Files::Koha_conf_xml::Default[$site_name] ~> Class["::koha::zebra::service"]

	# # koha-conf.xml parameters specific to koha::zebra::site.

	# # Only configure these options if this Zebra server is a public SRU server.
	# # Otherwise, configure fora local-only server.
	# if ($public_sru_server == true or $_biblioserver_public_sru_server == true or $_authorityserver_public_sru_server == true)
	# {
		# ::Koha::Files::Koha_conf_xml::Default <| title == $site_name |>
		# {
			# listen					=> true,
			# server					=> true,
			# serverinfo				=> true,

			# biblioserver				=> true,
			# authorityserver				=> true,

			# biblioserver_public_sru_server		=> $_biblioserver_public_sru_server,
			# biblioserver_sru_host			=> $_biblioserver_sru_host,
			# biblioserver_sru_port			=> $_biblioserver_sru_port,
			# biblioserver_sru_database		=> $_biblioserver_sru_database,

			# authorityserver_public_sru_server	=> $_authorityserver_public_sru_server,
			# authorityserver_sru_host		=> $_authorityserver_sru_host,
			# authorityserver_sru_port		=> $_authorityserver_sru_port,
			# authorityserver_sru_database		=> $_authorityserver_sru_database,
		# }
	# }
	# else
	# {
		# ::Koha::Files::Koha_conf_xml::Default <| title == $site_name |>
		# {
			# listen		=> true,
			# server		=> true,
			# serverinfo	=> true,

			# biblioserver	=> true,
			# authorityserver	=> true,
		# }
	# }

	# # Required configuration files for the Zebra index.
	# file
	# { "$koha_site_dir/$site_name/zebra-biblios.cfg":
		# ensure	=> $ensure,
		# owner	=> $koha_site_dir_conf_file_owner,
		# group	=> $_koha_user,
		# mode	=> $koha_site_dir_conf_file_mode,
		# content	=> template("koha/zebra-biblios-site.cfg.erb"),
		# require	=> [ Class["::koha::zebra"], ::Koha::User[$_koha_user] ],
		# notify	=> Class["::koha::zebra::service"],
	# }

	# file
	# { "$koha_site_dir/$site_name/zebra-biblios-dom.cfg":
		# ensure	=> $ensure,
		# owner	=> $koha_site_dir_conf_file_owner,
		# group	=> $_koha_user,
		# mode	=> $koha_site_dir_conf_file_mode,
		# content	=> template("koha/zebra-biblios-dom-site.cfg.erb"),
		# require	=> [ Class["::koha::zebra"], ::Koha::User[$_koha_user] ],
		# notify	=> Class["::koha::zebra::service"],
	# }

	# file
	# { "$koha_site_dir/$site_name/zebra-authorities.cfg":
		# ensure	=> $ensure,
		# owner	=> $koha_site_dir_conf_file_owner,
		# group	=> $_koha_user,
		# mode	=> $koha_site_dir_conf_file_mode,
		# content	=> template("koha/zebra-authorities-site.cfg.erb"),
		# require	=> [ Class["::koha::zebra"], ::Koha::User[$_koha_user] ],
		# notify	=> Class["::koha::zebra::service"],
	# }

	# file
	# { "$koha_site_dir/$site_name/zebra-authorities-dom.cfg":
		# ensure	=> $ensure,
		# owner	=> $koha_site_dir_conf_file_owner,
		# group	=> $_koha_user,
		# mode	=> $koha_site_dir_conf_file_mode,
		# content	=> template("koha/zebra-authorities-dom-site.cfg.erb"),
		# require	=> [ Class["::koha::zebra"], ::Koha::User[$_koha_user] ],
		# notify	=> Class["::koha::zebra::service"],
	# }

	# file
	# { "$koha_site_dir/$site_name/zebra.passwd":
		# ensure	=> $ensure,
		# owner	=> $koha_site_dir_conf_file_owner,
		# group	=> $_koha_user,
		# mode	=> $koha_site_dir_passwd_file_mode,
		# content	=> template("koha/zebra.passwd.erb"),
		# require	=> [ Class["::koha::zebra"], ::Koha::User[$_koha_user] ],
		# notify	=> Class["::koha::zebra::service"],
	# }

	# # Start the Koha zebra service, if it hasn't been already.
	# include koha::zebra::service
}
