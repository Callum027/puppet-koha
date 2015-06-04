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
	$zebra_password,

	$koha_site_dir			= $::koha::params::koha_site_dir,
	$koha_language			= $::koha::params::koha_language,
	$koha_marc_format		= $::koha::params::koha_marc_format,

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

	# Generate the Koha user, if it hasn't been made already.
	unless (defined(::Koha::User[$_koha_user]))
	{
		::koha::user { $_koha_user: }
	}

	# Generate and install Zebra config files.
	unless (defined(File["$koha_site_dir/$site_name"]))
	{
		if ($ensure == "present")
		{
			$directory_ensure = "directory"
		}
		else
		{
			$directory_ensure = $ensure
		}

		file
		{ "$koha_site_dir/$site_name":
			ensure	=> $directory_ensure,
			owner	=> $koha_user_real,
			group	=> $koha_user_real,
			mode	=> 755,
			require	=> [ Class["::koha::zebra"], ::Koha::User[$koha_user_real] ],
		}
	}

	file
	{ "$koha_site_dir/$site_name/zebra-biblios.cfg":
		ensure	=> $ensure,
		owner	=> root,
		group	=> $koha_user_real,
		mode	=> 640,
		content	=> template("koha/zebra-biblios-site.cfg.erb"),
		require	=> [ Class["::koha::zebra"], ::Koha::User[$koha_user_real] ],
		notify	=> Class["::koha::zebra::service"],
	}

	file
	{ "$koha_site_dir/$site_name/zebra-biblios-dom.cfg":
		ensure	=> $ensure,
		owner	=> root,
		group	=> $koha_user_real,
		mode	=> 640,
		content	=> template("koha/zebra-biblios-dom-site.cfg.erb"),
		require	=> [ Class["::koha::zebra"], ::Koha::User[$koha_user_real] ],
		notify	=> Class["::koha::zebra::service"],
	}

	file
	{ "$koha_site_dir/$site_name/zebra-authorities.cfg":
		ensure	=> $ensure,
		owner	=> root,
		group	=> $koha_user_real,
		mode	=> 640,
		content	=> template("koha/zebra-authorities-site.cfg.erb"),
		require	=> [ Class["::koha::zebra"], ::Koha::User[$koha_user_real] ],
		notify	=> Class["::koha::zebra::service"],
	}

	file
	{ "$koha_site_dir/$site_name/zebra-authorities-dom.cfg":
		ensure	=> $ensure,
		owner	=> root,
		group	=> $koha_user_real,
		mode	=> 640,
		content	=> template("koha/zebra-authorities-dom-site.cfg.erb"),
		require	=> [ Class["::koha::zebra"], ::Koha::User[$koha_user_real] ],
		notify	=> Class["::koha::zebra::service"],
	}

	file
	{ "$koha_site_dir/$site_name/zebra.passwd":
		ensure	=> $ensure,
		owner	=> root,
		group	=> $koha_user_real,
		mode	=> 640,
		content	=> template("koha/zebra.passwd.erb"),
		require	=> [ Class["::koha::zebra"], ::Koha::User[$koha_user_real] ],
		notify	=> Class["::koha::zebra::service"],
	}

	# Start the Koha zebra service, if it hasn't been already.
	# $ koha-start-zebra "$name"
	# $ koha-indexer --start "$name"
}
