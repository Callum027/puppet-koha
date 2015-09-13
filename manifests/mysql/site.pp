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
define koha::mysql::site
(
	$ensure			= present,
	$site_name		= $name,

	$database		= undef, # Defined in resource body
	$hostname		= undef, # Defined in resource body
	$port			= "3306",
	$user			= undef, # Defined in resource body

	$hostname_use_fqdn	= false,

	$sql			= undef,

	$pass
)
{
	##
	# Check for required resources.
	##

	unless (defined(Class["::koha::mysql"]))
	{
		fail("You must include the Koha MySQL base class before setting up a Koha MySQL database")
	}

	##
	# Processed default parameters.
	##

	$_database = pick($database, "koha_${site_name}")
	$_user = pick($user, $_database)

	if ($hostname_use_fqdn == true)
	{
		$_hostname = pick($hostname, $::fqdn)
	}
	else
	{
		$_hostname = pick($hostname, $::ipaddress)
	}


	##
	# Resource definitons.
	##

	# Set up MySQL database for this instance.
	::mysql::db
	{ $_database:
		user		=> $_user,
		password	=> $pass,
		host		=> '%',
		grant		=> 'ALL',
		sql		=> $sql,

		require		=> Class["::koha::mysql"],
	}

	# Database configuration for the Koha instance.
	::koha::db::site
	{ $site_name:
		db_scheme	=> "mysql",
		database	=> $_database,
		hostname	=> $_hostname,
		port		=> $port,
		user		=> $_user,
		pass		=> $pass,
	}
}
