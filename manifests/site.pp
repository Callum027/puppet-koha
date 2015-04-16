# == Class: koha::site
#
# Full description of class koha here.
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
define koha::site
(
	$ensure			= present,

	$site_name		= $name,
	$site_user		= "$site_name-koha",
	$mysql_password		= undef,
	$staff_password		= undef,

	$koha_site_dir		= $koha::params::koha_site_dir,
	$koha_language		= $koha::params::koha_language,
	$marc_format		= $koha::params::koha_marc_format,
	$biblios_config		= $koha::params::koha_zebra_biblios_config,
	$authorities_config	= $koha::params::koha_zebra_authorities_config,

	$koha_zebra_services	= $koha::params::koha_zebra_services,

	$pwgen			= $koha::params::pwgen,
	$sed			= $koha::params::sed,
	$test			= $koha::params::test
) inherits koha::params
{
	# If a password wasn't passed into the resource, automatically generate it.
	if ($mysql_password == undef)
	{
		$mysql_password = generate("$pwgen -s 16 1")
	}

	if ($staff_password == undef)
	{
		$staff_password = generate("$pwgen -s 12 1")
	}

	# Set up MySQL database for this instance.

	# Generate and install Apache site-available file and log dir.

	# Generate and install main Koha config file.

	# Zebra??

	# Create a GPG-encrypted file for requesting a DB to be set up.

	# Re-fetch the passwords from the config we've generated, allows it
	# to be different from what we set, in case the user had to change
	# something.

	# Use the default database content if that exists.

		# Populate the database with default content.

		# Change the default user's password.

		# Upgrade the database schema, just in case the dump was from an 
		# old version.

	# Reconfigure Apache.

	# Zebra again?? Indexer??
}
