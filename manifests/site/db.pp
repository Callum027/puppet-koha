# == Class: koha::mysql::site
#
# Add a Koha MySQL database for the given site name.
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
define koha::site::db
(
	$ensure			= "present",
	$site_name		= $name,

	$db_scheme		= $::koha::params::koha_conf_xml::config_db_scheme,
	$database,
	$port,
	$user,
	$pass
)
{
	if ($ensure == "present")
	{
		validate_re($config_db_scheme, "^mysql$", "invalid database scheme '$config_db_scheme'")

		if (is_string($db_port))
		{
			validate_re($db_port, "^[0-9]*$", "the given parameter is not a valid port number")
		}
		else
		{
			validate_integer($db_port)
		}

		validate_string($config_database, $config_hostname, $config_user, $config_pass)

		::Koha::Files::Koha_conf_xml::Default <| site_name == $site_name |>
		{
			config_db_scheme	=> $db_scheme,
			config_database		=> $database,
			config_port		=> $port,
			config_user		=> $user,
			config_pass		=> $pass,
		}
	}
}
