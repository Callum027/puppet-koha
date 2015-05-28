# == Class: koha::params
#
# Defines values for other classes in the Koha module to use.
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
#
# === Authors
#
# Callum Dickinson <callum@huttradio.co.nz>
#
# === Copyright
#
# Copyright 2015 Callum Dickinson.
#
class koha::params
{
	case $::osfamily
	{
		'Debian':
		{
			# Executable files.
			$a2dismod				= "/usr/sbin/a2dismod"
			$a2enmod				= "/usr/sbin/a2enmod"
			$echo					= "/bin/echo"
			$grep					= "/bin/grep"
			$koha_create				= "/usr/sbin/koha-create"
			$koha_translate				= "/usr/sbin/koha-translate"
			$mysql					= "/usr/bin/mysql"
			$nologin				= "/usr/sbin/nologin"
			$pwgen					= "/usr/bin/pwgen"
			$sed					= "/bin/sed"
			$test					= "/usr/bin/test"

			# Apache configuration variables.
			$apache_sites_available_dir		= "/etc/apache2/sites-available"
			$apache_sites_enabled_dir		= "/etc/apache2/sites-enabled"

			# Koha configuration variables.
			$koha_repo_release			= "stable"
			$koha_packages				= [ "koha-common" ]
			$koha_services				= [ "koha-common" ]

			$koha_language				= "en"
			$koha_config_dir			= "/etc/koha"
			$koha_lib_dir				= "/var/lib/koha"
			$koha_log_dir				= "/var/log/koha"
			$koha_site_dir				= "/etc/koha/sites"
			
			# Koha Zebra configuration variables.
			$koha_zebra_packages			= $koha_packages
			$koha_zebra_services			= $koha_services

			$koha_zebra_marc_format			= "marc21"

			$koha_zebra_biblios_config		= "zebra-biblios.cfg"
			$koha_zebra_authorities_config		= "zebra_authorities.cfg"

			$koha_zebra_biblios_indexing_mode	= "dom"
			$koha_zebra_authorities_indexing_mode	= "dom"

			# MySQL configuration variables.
			$mysql_adminuser			= "1"
		}

		# RedHat support will come at a later time!

		default:
		{
			fail("Sorry, but the koha module does not support the $::osfamily OS family at this time")
		}
	}
}
