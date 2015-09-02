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
define koha::site_temp
(
	$ensure				= "present",
	$site_name			= $name,
)
{
	##
	# Collect and/or configure the servers for each component, as well as ensure external
	# resources for this server are available.
	##

	# System resources (koha::user)
	::koha::user
	{ "$site_name-koha":
		notify	=> Class["::apache::service"],
	}

	# Required folders for configuration and log files.
	::koha::log_dir
	{ $site_name:
		koha_user	=> "$site_name-koha",
		require		=> Class["::koha"],
		notify		=> Class["::apache::service"],
	}

	file
	{ "$koha_site_dir/$site_name":
		ensure	=> $directory_ensure,
		owner	=> $_koha_user,
		group	=> $_koha_user,
		mode	=> $koha_site_dir_mode,

		require	=> [ Class["::koha"], ::Koha::User[$_koha_user] ],
		before	=> Class["::apache::service"],
		notify	=> Class["::koha::service"],
	}

	# Apache HTTP Server.
	::Koha::User["$site_name-koha"] -> Class["::koha::service"] ~> Class["::apache::service"]

	# Apache vhost for the Koha site.
	::koha::apache::site
	{ $site_name:
		ensure		=> $ensure,
	}

	# koha-conf.xml.
	::koha::files::koha_conf_xml { $site_name: }

	::koha::files::koha_conf_xml::config
	{ $site_name:
		database	=> "koha_$site_name",
		hostname	=> "db.kohaaas.catalyst.net.nz",
		user		=> "koha_$site_name",
		password	=>  $site_name,
	}

	::koha::files::koha_conf_xml::biblioserver
	::koha::files::koha_conf_xml::authorityserver

	::koha::files::koha_conf_xml::

	# Zebra.
	::koha::zebra::site_temp
	{ $site_name:
	}
}
