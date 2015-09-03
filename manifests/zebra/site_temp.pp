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
define koha::zebra::site_temp
(
	$ensure					= "present",
	$site_name				= $name,
)
{
	$_koha_user = "$site_name-koha"

	unless (defined(Class["::koha::zebra"]))
	{
		fail("You must include the Koha Zebra base class before setting up a Koha Zebra site index")
	}

	# Set up the Koha Zebra service if it hasn't already.
	unless (defined(Class["::koha::zebra::service"]))
	{
		include ::koha::zebra::service
	}

	# Establish the relationship between the Zebra package installation, koha-conf.xml
	# and the Zebra service.
	Class["::koha::zebra"] -> ::Koha::Files::Koha_conf_xml[$site_name] ~> Class["::koha::zebra::service"]

	# koha-conf.xml parameters specific to koha::zebra::site.

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
