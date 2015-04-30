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

	$mysql_adminuser	= $koha::params::mysql_adminuser,

	$mysql_db		= "koha_$site_name",
	$mysql_user		= $mysql_db,

	$mysql_password,
	$staff_password
)
{
	require koha::params

	# Set up MySQL database for this instance.
	mysql::db
	{ $mysql_db:
		user		=> $mysql_user,
		password	=> $mysql_password,
		host		=> 'localhost',
		grant		=> 'ALL',
	}

	# Re-fetch the passwords from the config we've generated, allows it
	# to be different from what we set, in case the user had to change
	# something.

	# TODO: Use the default database content if that exists.
	# Step 1: get the user to pass in a default SQL parameters file
	# Step 2: check if it was passed in and check if it exiss
	# Step 3: pass it to MySQL

	# TODO: Populate the database with default content.

	# Change the default user's password.
	$staff_digest = md5($staff_password)

	exec
	{ "koha::mysql::site::mysql_change_default_password":
		command	=> "$echo 'USE \`$mysql_db\`; UPDATE borrowers SET password = '$staff_digest' WHERE borrowernumber = $mysql_admin_user;' | $mysql --host='localhost' --user='$mysql_user' --password='$mysql_password'",
	}

	# TODO: Upgrade the database schema, just in case the dump was from an old version.
}
