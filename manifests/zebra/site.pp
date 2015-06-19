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
	$ensure				= "present",

	$site_name			= $name,

	$koha_user			= undef, # Defined in resource body
	$koha_zebra_password,

	$koha_log_dir			= $::koha::params::koha_log_dir,
	$koha_log_dir_mode		= $::koha::params::koha_log_dir_mode,
	$koha_site_dir			= $::koha::params::koha_site_dir,
	$koha_site_dir_mode		= $::koha::params::koha_site_dir_mode,
	$koha_site_dir_conf_file_mode	= $::koha::params::koha_site_dir_conf_file_mode,
	$koha_site_dir_passwd_file_mode	= $::koha::params::koha_site_dir_passwd_file_mode,

	$koha_language			= $::koha::params::koha_language,
	$koha_zebra_marc_format		= $::koha::params::koha_zebra_marc_format,

	$koha_zebra_biblios_config	= $::koha::params::koha_zebra_biblios_config,
	$koha_zebra_authorities_config	= $::koha::params::koha_zebra_authorities_config,

	$pwgen				= $::koha::params::pwgen,
	$sed				= $::koha::params::sed,
	$test				= $::koha::params::test
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
			require	=> [ Class["::koha:zebra"], ::Koha::User[$_koha_user] ],
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
