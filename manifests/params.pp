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
			$apache_sites_dir_conf_file_mode	= 640

			# MySQL configuration variables.
			$mysql_bind_address			= "0.0.0.0"
			$mysql_port				= 3306

			# Koha configuration variables.
			$koha_repo_release			= "stable"
			$koha_packages				= [ "koha-common" ]
			$koha_services				= [ "koha-common" ]

			$koha_language				= "en"
			$koha_config_dir			= "/etc/koha"
			$koha_lib_dir				= "/var/lib/koha"

			$koha_log_dir				= "/var/log/koha"
			$koha_log_dir_mode			= 755

			$koha_site_dir				= "/etc/koha/sites"
			$koha_site_dir_mode			= 755
			$koha_site_dir_conf_file_mode		= 640
			$koha_site_dir_passwd_file_mode		= 640

			$koha_site_opac_port			= "80"
			$koha_site_intra_port			= "80"
			
			# Koha Zebra configuration variables.
			$koha_zebra_packages			= [ "koha-common" ]
			$koha_zebra_services			= [ "koha-common" ]

			$koha_zebra_z3950_port			= "210"
			$koha_zebra_sru_biblios_port		= "9998"
			$koha_zebra_sru_authorities_port	= "9999"

			$koha_zebra_sru_biblios_database	= "biblios"
			$koha_zebra_sru_authorities_database	= "authority"

			$koha_zebra_biblioserver		= $koha_zebra_sru_biblios_database
			$koha_zebra_authorityserver		= $koha_zebra_sru_authorities_database

			$koha_zebra_marc_format			= "marc21"

			$koha_zebra_biblios_config		= "zebra-biblios-dom.cfg"
			$koha_zebra_authorities_config		= "zebra-authorities-dom.cfg"

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
