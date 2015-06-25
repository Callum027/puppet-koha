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

	# Global koha-conf.xml options.
	$koha_user				= undef, # Defined in resource body
	$koha_zebra_password,

	$koha_config_dir			= $::koha::params::koha_config_dir,
	$koha_site_dir				= $::koha::params::koha_site_dir,
	$koha_site_dir_mode			= $::koha::params::koha_site_dir_mode,
	$koha_site_dir_conf_file_mode		= $::koha::params::koha_site_dir_conf_file_mode,
	$koha_site_opac_port			= $::koha::params::koha_site_opac_port,
	$koha_site_intra_port			= $::koha::params::koha_site_intra_port,

	$koha_lib_dir				= $::koha::params::koha_lib_dir,
	$koha_log_dir				= $::koha::params::koha_log_dir,
	$koha_log_dir_mode			= $::koha::params::koha_log_dir_mode,

	$koha_zebra_biblios_config		= $::koha::params::koha_zebra_biblios_config,
	$koha_zebra_authorities_config		= $::koha::params::koha_zebra_authorities_config,

	$koha_zebra_biblios_indexing_mode	= $::koha::params::koha_zebra_biblios_indexing_mode,
	$koha_zebra_authorities_indexing_mode	= $::koha::params::koha_zebra_authorities_indexing_mode,

	$koha_zebra_marc_format			= $::koha::params::koha_zebra_marc_format,

	$koha_zebra_server_biblios_port		= $::koha::params::koha_zebra_sru_biblios_port,

	$koha_zebra_server_authorities_port	= $::koha::params::koha_zebra_sru_authorities_port,

	$koha_zebra_biblioserver		= $::koha::params::koha_zebra_biblioserver,
	$koha_zebra_authorityserver		= $::koha::params::koha_zebra_authorityserver,

	# Koha Zebra-specific koha-conf.xml configuration options.
	$public_z3950_server			= false,
	$koha_zebra_sru_hostname		= undef, # Defined in resource body

	$koha_zebra_sru_biblios_port		= $::koha::params::koha_zebra_sru_biblios_port,

	$koha_zebra_sru_authorities_port	= $::koha::params::koha_zebra_sru_authorities_port,

	$koha_zebra_sru_biblios_database	= $::koha::params::koha_zebra_sru_biblios_database,

	$koha_zebra_sru_authorities_database	= $::koha::params::koha_zebra_sru_authorities_database
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

	# Set the default value for the Koha user account.
	if ($koha_user == undef)
	{
		$_koha_user = "$site_name-koha"
	}
	else
	{
		$_koha_user = $koha_user
	}

	# Set the default value for the public Zebra Z39.50 server.
	if ($koha_zebra_sru_hostname == undef)
	{
		$_koha_zebra_sru_hostname = "$site_name.$::domain"
	}
	else
	{
		$_koha_zebra_sru_hostname = $koha_zebra_sru_hostname
	}

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

	if (defined(File["$koha_log_dir/$site_name"]))
	{
		Class["::koha::zebra"] -> File["$koha_log_dir/$site_name"] ~> Class["::koha::zebra::service"]
	}
	else
	{
		file
		{ "$koha_log_dir/$site_name":
			ensure	=> $directory_ensure,
			owner	=> $_koha_user,
			group	=> $_koha_user,
			mode	=> $koha_log_dir_mode,
			require	=> [ Class["::koha::zebra"], ::Koha::User[$_koha_user] ],
			notify	=> Class["::koha::zebra::service"],
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

	# Add global configuration options to koha-conf.xml, if it has not been defined already.
	unless (defined(::Koha::Files::Koha_conf_xml_site[$site_name]))
	{
		::koha::files::koha_conf_xml_site
		{ $site_name:
			# Global parameters.
			koha_user				=> $_koha_user,
			koha_zebra_password			=> $koha_zebra_password,

			koha_config_dir				=> $koha_config_dir,
			koha_site_dir				=> $koha_site_dir,
			koha_site_dir_conf_file_mode		=> $koha_site_dir_conf_file_mode,
			koha_lib_dir				=> $koha_lib_dir,
			koha_log_dir				=> $koha_log_dir,
			koha_log_dir_mode			=> $koha_log_dir_mode,

			koha_zebra_biblios_config		=> $koha_zebra_biblios_config,
			koha_zebra_authorities_config		=> $koha_zebra_authorities_config,

			koha_zebra_biblios_indexing_mode	=>$koha_zebra_biblios_indexing_mode,
			koha_zebra_authorities_indexing_mode	=>$koha_zebra_authorities_indexing_mode,

			koha_zebra_marc_format			=> $koha_zebra_marc_format,

			koha_zebra_server_biblios_port		=> $koha_zebra_server_biblios_port,
			koha_zebra_server_authorities_port	=> $koha_zebra_server_authorities_port,

			koha_zebra_biblioserver			=> $koha_zebra_biblioserver,
			koha_zebra_authorityserver		=> $koha_zebra_authorityserver,
		}
	}

	# Establish the relationship between the Zebra package installation, koha-conf.xml
	# and the Zebra service.
	Class["::koha::zebra"] -> ::Koha::Files::Koha_conf_xml_site[$site_name] ~> Class["::koha::zebra::service"]

	# Parameters specific to koha::zebra::site.
	::Koha::Files::Koha_conf_xml_site[$site_name]
	{
		public_z3950_server			=> $public_z3950_server,
		koha_zebra_sru_hostname			=> $_koha_zebra_sru_hostname,

		koha_zebra_sru_biblios_port		=> $koha_zebra_sru_biblios_port,
		koha_zebra_sru_authorities_port		=> $koha_zebra_sru_authorities_port,

		koha_zebra_sru_biblios_database		=> $koha_zebra_sru_biblios_database,
		koha_zebra_sru_authorities_database	=> $koha_zebra_sru_authorities_database,
	}

	# Required configuration files for the Zebra index.
	file
	{ "$koha_site_dir/$site_name/zebra-biblios.cfg":
		ensure	=> $ensure,
		owner	=> root,
		group	=> $_koha_user,
		mode	=> $koha_site_dir_conf_file_mode,
		content	=> template("koha/zebra-biblios-site.cfg.erb"),
		require	=> [ Class["::koha::zebra"], ::Koha::User[$_koha_user] ],
		notify	=> Class["::koha::zebra::service"],
	}

	file
	{ "$koha_site_dir/$site_name/zebra-biblios-dom.cfg":
		ensure	=> $ensure,
		owner	=> root,
		group	=> $_koha_user,
		mode	=> $koha_site_dir_conf_file_mode,
		content	=> template("koha/zebra-biblios-dom-site.cfg.erb"),
		require	=> [ Class["::koha::zebra"], ::Koha::User[$_koha_user] ],
		notify	=> Class["::koha::zebra::service"],
	}

	file
	{ "$koha_site_dir/$site_name/zebra-authorities.cfg":
		ensure	=> $ensure,
		owner	=> root,
		group	=> $_koha_user,
		mode	=> $koha_site_dir_conf_file_mode,
		content	=> template("koha/zebra-authorities-site.cfg.erb"),
		require	=> [ Class["::koha::zebra"], ::Koha::User[$_koha_user] ],
		notify	=> Class["::koha::zebra::service"],
	}

	file
	{ "$koha_site_dir/$site_name/zebra-authorities-dom.cfg":
		ensure	=> $ensure,
		owner	=> root,
		group	=> $_koha_user,
		mode	=> $koha_site_dir_conf_file_mode,
		content	=> template("koha/zebra-authorities-dom-site.cfg.erb"),
		require	=> [ Class["::koha::zebra"], ::Koha::User[$_koha_user] ],
		notify	=> Class["::koha::zebra::service"],
	}

	file
	{ "$koha_site_dir/$site_name/zebra.passwd":
		ensure	=> $ensure,
		owner	=> root,
		group	=> $_koha_user,
		mode	=> $koha_site_dir_passwd_file_mode,
		content	=> template("koha/zebra.passwd.erb"),
		require	=> [ Class["::koha::zebra"], ::Koha::User[$_koha_user] ],
		notify	=> Class["::koha::zebra::service"],
	}

	# Start the Koha zebra service, if it hasn't been already.
	include koha::zebra::service
}
