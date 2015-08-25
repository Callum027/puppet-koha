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
	$ensure					= "present",
	$site_name				= $name,

	$koha_user				= undef, # Defined in resource body

	# Zebra options.
	$zebra_user				= $::koha::params::zebra_user,
	$zebra_password,

	$language				= $::koha::params::language,
	$marc_format				= $::koha::params::marc_format,

	# Global (both biblioserver and authorityserver) SRU server options.
	$public_sru_server			= false,
	$sru_host				= undef,
	$sru_port				= undef,

	# Biblioserver SRU options.
	$biblioserver_public_sru_server		= $::koha::params::koha_conf_xml::biblioserver_public_sru_server,
	$biblioserver_sru_host			= undef, # Defined in resource body
	$biblioserver_sru_port			= $::koha::params::koha_conf_xml::biblioserver_sru_port,
	$biblioserver_sru_database		= $::koha::params::koha_conf_xml::config_biblioserver,

	# Authorityserver SRU options.
	$authorityserver_public_sru_server	= $::koha::params::koha_conf_xml::authorityserver_public_sru_server,
	$authorityserver_sru_host		= undef, # Defined in resource body
	$authorityserver_sru_port		= $::koha::params::koha_conf_xml::authorityserver_sru_port,
	$authorityserver_sru_database		= $::koha::params::koha_conf_xml::config_authorityserver,

	# koha::params default values.
	$koha_log_dir				= $::koha::params::koha_log_dir,
	$koha_log_dir_mode			= $::koha::params::koha_log_dir_mode,
	$koha_site_dir				= $::koha::params::koha_site_dir,
	$koha_site_dir_mode			= $::koha::params::koha_site_dir_mode,
	$koha_site_dir_conf_file_owner		= $::koha::params::koha_site_dir_conf_file_owner,
	$koha_site_dir_conf_file_mode		= $::koha::params::koha_site_dir_conf_file_mode
)
{
	unless (defined(Class["::koha::zebra"]))
	{
		fail("You must include the Koha Zebra base class before setting up a Koha Zebra site index")
	}

	# Set up the Koha Zebra service if it hasn't already.
	unless (defined(Class["::koha::zebra::service"]))
	{
		include ::koha::zebra::service
	}

	$_koha_conf_xml = pick($koha_conf_xml, "${koha_site_dir}/${site_name}/koha-conf.xml")
	$_koha_user = pick($koha_user, "$site_name-koha")

	$_biblioserver_sru_host = pick($biblioserver_sru_host, "$site_name.$::domain")
	$_authorityserver_sru_host = pick($authorityserver_sru_host, "$site_name.$::domain")


	if ($ensure == "present")
	{
		$directory_ensure = "directory"
	}
	else
	{
		$directory_ensure = $ensure
	}

	# Generate the Koha user, and the log directory. But only if they
	# haven't been defined before. They also get defined in ::koha::site.
	if (defined(::Koha::User[$_koha_user]))
	{
		::Koha::User[$_koha_user] ~> Class["::koha::zebra::service"]
	}
	else
	{
		::koha::user
		{ $_koha_user:
			notify	=> Class["::koha::zebra::service"],
		}
	}

	if (defined(::Koha::Log_dir[$site_name]))
	{
		Class["::koha::zebra"] -> ::Koha::Log_dir[$site_name] ~> Class["::koha::zebra::service"]
	}
	else
	{
		::koha::log_dir
		{ $site_name:
			koha_user	=> $_koha_user,
			require		=> Class["::koha::zebra"],
			notify		=> Class["::koha::zebra::service"],
		}
	}

	# Generate and install Zebra config files.
	if (defined(File["$koha_site_dir/$site_name"]))
	{
		Class["::koha::zebra"] -> File["$koha_site_dir/$site_name"] ~> Class["::koha::zebra::service"]
	}
	else
	{
		file
		{ "$koha_site_dir/$site_name":
			ensure	=> $directory_ensure,
			owner	=> $_koha_user,
			group	=> $_koha_user,
			mode	=> 755,
			require	=> [ Class["::koha::zebra"], ::Koha::User[$_koha_user] ],
			notify	=> Class["::koha::zebra::service"],
		}
	}

	# Define the default koha-conf.xml resource with Zebra-centric options, if it has not been defined already.
	unless (defined(::Koha::Files::Koha_conf_xml::Default[$site_name]))
	{
		::koha::files::koha_conf_xml::default
		{ $site_name:
			file		=> $_koha_conf_xml,
			file_group	=> $_koha_user,

			config		=> false,
		}
	}

	# Establish the relationship between the Zebra package installation, koha-conf.xml
	# and the Zebra service.
	Class["::koha::zebra"] -> ::Koha::Files::Koha_conf_xml::Default[$site_name] ~> Class["::koha::zebra::service"]

	# koha-conf.xml parameters specific to koha::zebra::site.

	# Only configure these options if this Zebra server is a public SRU server.
	# Otherwise, configure fora local-only server.
	if ($public_sru_server == true or $_biblioserver_public_sru_server == true or $_authorityserver_public_sru_server == true)
	{
		::Koha::Files::Koha_conf_xml::Default <| title == $site_name |>
		{
			listen					=> true,
			server					=> true,
			serverinfo				=> true,

			biblioserver				=> true,
			authorityserver				=> true,

			biblioserver_public_sru_server		=> $_biblioserver_public_sru_server,
			biblioserver_sru_host			=> $_biblioserver_sru_host,
			biblioserver_sru_port			=> $_biblioserver_sru_port,
			biblioserver_sru_database		=> $_biblioserver_sru_database,

			authorityserver_public_sru_server	=> $_authorityserver_public_sru_server,
			authorityserver_sru_host		=> $_authorityserver_sru_host,
			authorityserver_sru_port		=> $_authorityserver_sru_port,
			authorityserver_sru_database		=> $_authorityserver_sru_database,
		}
	}
	else
	{
		::Koha::Files::Koha_conf_xml::Default <| title == $site_name |>
		{
			listen		=> true,
			server		=> true,
			serverinfo	=> true,

			biblioserver	=> true,
			authorityserver	=> true,
		}
	}

	# Required configuration files for the Zebra index.
	file
	{ "$koha_site_dir/$site_name/zebra-biblios.cfg":
		ensure	=> $ensure,
		owner	=> $koha_site_dir_conf_file_owner,
		group	=> $_koha_user,
		mode	=> $koha_site_dir_conf_file_mode,
		content	=> template("koha/zebra-biblios-site.cfg.erb"),
		require	=> [ Class["::koha::zebra"], ::Koha::User[$_koha_user] ],
		notify	=> Class["::koha::zebra::service"],
	}

	file
	{ "$koha_site_dir/$site_name/zebra-biblios-dom.cfg":
		ensure	=> $ensure,
		owner	=> $koha_site_dir_conf_file_owner,
		group	=> $_koha_user,
		mode	=> $koha_site_dir_conf_file_mode,
		content	=> template("koha/zebra-biblios-dom-site.cfg.erb"),
		require	=> [ Class["::koha::zebra"], ::Koha::User[$_koha_user] ],
		notify	=> Class["::koha::zebra::service"],
	}

	file
	{ "$koha_site_dir/$site_name/zebra-authorities.cfg":
		ensure	=> $ensure,
		owner	=> $koha_site_dir_conf_file_owner,
		group	=> $_koha_user,
		mode	=> $koha_site_dir_conf_file_mode,
		content	=> template("koha/zebra-authorities-site.cfg.erb"),
		require	=> [ Class["::koha::zebra"], ::Koha::User[$_koha_user] ],
		notify	=> Class["::koha::zebra::service"],
	}

	file
	{ "$koha_site_dir/$site_name/zebra-authorities-dom.cfg":
		ensure	=> $ensure,
		owner	=> $koha_site_dir_conf_file_owner,
		group	=> $_koha_user,
		mode	=> $koha_site_dir_conf_file_mode,
		content	=> template("koha/zebra-authorities-dom-site.cfg.erb"),
		require	=> [ Class["::koha::zebra"], ::Koha::User[$_koha_user] ],
		notify	=> Class["::koha::zebra::service"],
	}

	file
	{ "$koha_site_dir/$site_name/zebra.passwd":
		ensure	=> $ensure,
		owner	=> $koha_site_dir_conf_file_owner,
		group	=> $_koha_user,
		mode	=> $koha_site_dir_passwd_file_mode,
		content	=> template("koha/zebra.passwd.erb"),
		require	=> [ Class["::koha::zebra"], ::Koha::User[$_koha_user] ],
		notify	=> Class["::koha::zebra::service"],
	}

	# Start the Koha zebra service, if it hasn't been already.
	include koha::zebra::service
}
