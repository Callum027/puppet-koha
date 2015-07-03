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
	include ::koha::params::koha_conf_xml

	case $::osfamily
	{
		'Debian':
		{
			# Executable files.
			$a2dismod					= "/usr/sbin/a2dismod"
			$a2enmod					= "/usr/sbin/a2enmod"
			$echo						= "/bin/echo"
			$grep						= "/bin/grep"
			$koha_create					= "/usr/sbin/koha-create"
			$koha_translate					= "/usr/sbin/koha-translate"
			$mysql						= "/usr/bin/mysql"
			$nologin					= "/usr/sbin/nologin"
			$pwgen						= "/usr/bin/pwgen"
			$sed						= "/bin/sed"
			$test						= "/usr/bin/test"

			# Koha directories.
			$koha_config_dir				= "/etc/koha"
			$koha_doc_dir					= "/usr/share/doc/koha-common"
			$koha_lib_dir					= "/var/lib/koha"

			$koha_log_dir					= "/var/log/koha"
			$koha_log_dir_mode				= 755

			$koha_run_dir					= "/var/run/koha"
			$koha_share_dir					= "/usr/share/koha"

			$koha_site_dir					= "$koha_config_dir/sites"
			$koha_site_dir_mode				= 755
			$koha_site_dir_conf_file_owner			= "root"
			$koha_site_dir_conf_file_mode			= 640
			$koha_site_dir_passwd_file_mode			= 640

			$koha_spool_dir					= "/var/spool/koha"

			# Apache configuration variables.
			$apache_sites_available_dir			= "/etc/apache2/sites-available"
			$apache_sites_enabled_dir			= "/etc/apache2/sites-enabled"
			$apache_sites_dir_conf_file_mode		= 640

			# MySQL configuration variables.
			$mysql_bind_address				= "0.0.0.0"
			$mysql_port					= 3306

			# Koha configuration variables.
			$koha_repo_release				= "stable"
			$koha_packages					= [ "koha-common" ]
			$koha_services					= [ "koha-common" ]

			$koha_language					= "en"

			$koha_site_opac_port				= "80"
			$koha_site_intra_port				= "80"
			
			# Zebra configuration variables.
			$zebra_packages					= [ "koha-common" ]
			$zebra_services					= [ "koha-common" ]

			$zebra_user					= "kohauser"

			# MySQL configuration variables.
			$mysql_adminuser				= "1"
		}

		# RedHat support will come at a later time!

		default:
		{
			fail("Sorry, but the koha module does not support the $::osfamily OS family at this time")
		}
	}
}
