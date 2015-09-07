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

	$mysql_db		= undef, # Defined in resource body
	$mysql_port		= "3306",
	$mysql_user		= undef, # Defined in resource body

	$mysql_password
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

	$_mysql_db = pick($mysql_db, "koha_${site_name}")
	$_mysql_user = pick($mysql_user, $_mysql_db)


	##
	# Resource definitons.
	##

	# Set up MySQL database for this instance.
	::mysql::db
	{ $_mysql_db:
		user		=> $_mysql_user,
		password	=> $mysql_password,
		host		=> '%',
		grant		=> 'ALL',
		require		=> Class["::koha::mysql"],
	}

	# Database configuration for the Koha instance.
	::koha::db::site
	{ $site_name:
		db_scheme	=> "mysql",
		database	=> $_mysql_db,
		port		=> $mysql_port,
		user		=> $_mysql_user,
		pass		=> $mysql_password,
	}
}
