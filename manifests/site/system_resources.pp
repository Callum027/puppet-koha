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
define koha::site::system_resources
(
	$ensure				= "present",
	$site_name			= $name,

	# Koha options.
	$koha_user			= undef, # Defined in resource body

	# koha::params default values.
	$koha_site_dir			= $::koha::params::koha_site_dir
)
{
	##
	# Add the Koha user to required resources.
	##
	if ($ensure == "present")
	{
		::Koha::Apache::Site <| site_name == $site_name |>
		{
			koha_user	=> $_koha_user,
		}

		::Koha::Files::Koha_conf_xml <| site_name == $site_name |>
		{
			file_group	=> $_koha_user,
		}
	}

	##
	# Processed default parameters.
	##
	$_koha_user = pick($koha_user, "$site_name-koha")

	##
	# Resource declaration.
	##

	if ($ensure == "present")
	{
		$directory_ensure = "directory"
	}
	else
	{
		$directory_ensure = $ensure
	}

	# Generate the Koha user, and the log directory.
	::koha::user
	{ $_koha_user:
		notify	=> Class["::apache::service"],
	}

	# Required folders for configuration and log files.
	::koha::log_dir
	{ $site_name:
		koha_user	=> $_koha_user,
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
}
