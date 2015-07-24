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
define koha::files::koha_conf_xml::config
(
	$ensure			= "present",
	$site_name		= $name,

	# Config options.
	$db_scheme		= $::koha::params::koha_conf_xml::config_db_scheme,
	$database,
	$hostname,
	$port			= undef, # Defined in resource body
	$user,
	$pass,

	$biblioserver		= $::koha::params::koha_conf_xml::config_biblioserver,
	$biblioservershadow	= $::koha::params::koha_conf_xml::config_biblioservershadow,

	$authorityserver	= $::koha::params::koha_conf_xml::config_authorityserver,
	$authorityservershadow	= $::koha::params::koha_conf_xml::config_authorityservershadow,

	$pluginsdir		= undef, # Defined in resource body
	$enable_plugins		= $::koha::params::koha_conf_xml::config_enable_plugins,

	$intranetdir		= $::koha::params::koha_conf_xml::config_intranetdir,
	$opacdir		= $::koha::params::koha_conf_xml::config_opacdir,
	$opachtdocs		= $::koha::params::koha_conf_xml::config_opachtdocs,
	$intrahtdocs		= $::koha::params::koha_conf_xml::config_intrahtdocs,
	$includes		= $::koha::params::koha_conf_xml::config_includes,
	$logdir			= $::koha::params::koha_conf_xml::config_logdir,
	$docdir			= $::koha::params::koha_conf_xml::config_docdir,
	$backupdir		= undef, # Defined in resource body

	$backup_db_via_tools	= $::koha::params::koha_conf_xml::config_backup_db_via_tools,
	$backup_conf_via_tools	= $::koha::params::koha_conf_xml::config_backup_conf_via_tools,

	$pazpar2url		= undef,

	$install_log		= $::koha::params::koha_conf_xml::config_install_log,

	$useldapserver		= $::koha::params::koha_conf_xml::config_useldapserver,
	$useshibboleth		= $::koha::params::koha_conf_xml::config_useshibboleth,

	$zebra_bib_index_mode,
	$zebra_auth_index_mode,

	$zebra_lockdir		= undef, # Defined in resource body
	$use_zebra_facets	= $::koha::params::koha_conf_xml::config_use_zebra_facets,
	$queryparser_config	= $::koha::params::koha_conf_xml::config_queryparser_config,

	# koha::params default values.
	$koha_lib_dir		= $::koha::params::koha_lib_dir,
	$koha_run_dir		= $::koha::params::koha_run_dir,
	$koha_spool_dir		= $::koha::params::koha_spool_dir
)
{
	validate_re($db_scheme, [ "^mysql$", "^postgresql$" ], "the only supported database schemes are 'mysql' and 'postgresql'")

	if ($port != undef)
	{
		$_port = $port
	}
	elsif ($db_scheme == "mysql")
	{
		$_port = $::koha::params::koha_conf_xml::config_mysql_port
	}
	elsif ($db_scheme == "postgresql")
	{
		$_port = $::koha::params::koha_conf_xml::config_postgresql_port
	}

	$_pluginsdir = pick($pluginsdir, "${koha_lib_dir}/${site_name}/plugins")
	$_backupdir = pick($backupdir, "${koha_spool_dir}/${site_name}")

	$_zebra_lockdir = pick($zebra_lockdir, "${koha_run_dir}/${site_name}")

	::concat::fragment
	{ "${site_name}::koha_conf_xml::config":
		target	=> "${site_name}::koha_conf_xml",
		ensure	=> $ensure,
		content	=> template("koha/koha_conf_xml/config.xml.erb"),
		order	=> "05",
	}
}
