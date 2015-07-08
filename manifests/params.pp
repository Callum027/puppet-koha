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
			##
			# System-specific default configuration variables.
			##

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

			# Apache directories.
			$apache_sites_available_dir			= "/etc/apache2/sites-available"
			$apache_sites_enabled_dir			= "/etc/apache2/sites-enabled"
			$apache_sites_dir_conf_file_mode		= 640

			# Koha packages and services.
			$koha_repo_release				= "stable"
			$koha_packages					= [ "koha-common" ]
			$koha_services					= [ "koha-common" ]

			# Zebra packages and services.
			$zebra_packages					= [ "koha-common" ]
			$zebra_services					= [ "koha-common" ]

			# Apache and MySQL packages and services are handled by their
			# official modules.
		}

		# RedHat support will come at a later time!

		default:
		{
			fail("Sorry, but the koha module does not support the $::osfamily OS family at this time")
		}
	}

	##
	# Resource-specific default configuration variables.
	##

	# koha::site default values.
	$site_elasticsearch		= false

	$site_collect_db		= true
	$site_collect_elasticsearch	= true
	$site_collect_memcached		= true
	$site_collect_zebra		= true

	$site_opac_port			= "80"
	$site_intra_port		= "80"

	##
	# Default configuration variables for specific software components.
	# koha-conf.xml handling is in koha::params::koha_conf_xml.
	##

	# MySQL configuration variables.
	$mysql_adminuser		= "1"
	$mysql_bind_address		= "0.0.0.0"
	$mysql_port			= 3306

	# Koha configuration variables.
	$koha_language			= "en"
	
	# Zebra configuration variables.
	$zebra_user			= "kohauser"
}
