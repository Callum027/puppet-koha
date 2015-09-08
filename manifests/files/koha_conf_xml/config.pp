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
	$db_scheme		= undef, # Filled in by ::koha::site::db
	$database		= undef, # Filled in by ::koha::site::db
	$hostname		= undef, # Filled in by ::koha::site::db
	$port			= undef, # Filled in by ::koha::site::db
	$user			= undef, # Filled in by ::koha::site::db
	$pass			= undef, # Filled in by ::koha::site::db

	$biblioserver		= "biblios",
	$biblioservershadow	= 1,

	$authorityserver	= "authorities",
	$authorityservershadow	= 1,

	$pluginsdir		= undef, # Defined in resource body
	$enable_plugins		= 0,

	$intranetdir		= undef, # Defined in resource body
	$opacdir		= undef, # Defined in resource body
	$opachtdocs		= undef, # Defined in resource body
	$intrahtdocs		= undef, # Defined in resource body
	$includes		= undef, # Defined in resource body
	$logdir			= undef, # Defined in resource body
	$docdir			= $::koha::params::koha_doc_dir,
	$backupdir		= undef, # Defined in resource body

	$backup_db_via_tools	= 0,
	$backup_conf_via_tools	= 0,

	$pazpar2url		= undef,

	$install_log		= undef, # Defined in resource body

	$useldapserver		= 0,
	$useshibboleth		= 0,

	$zebra_bib_index_mode	= undef, # Filled in by ::koha::site::zebra
	$zebra_auth_index_mode	= undef, # Filled in by ::koha::site::zebra

	$zebra_lockdir		= undef, # Defined in resource body
	$use_zebra_facets	= 1,
	$queryparser_config	= undef, # Defined in resource body
	$log4perl_conf		= undef, # Defined in resource body

	# koha::params default values.
	$koha_config_dir	= $::koha::params::koha_config_dir,
	$koha_doc_dir		= $::koha::params::koha_doc_dir,
	$koha_lib_dir		= $::koha::params::koha_lib_dir,
	$koha_lock_dir		= $::koha::params::koha_lock_dir,
	$koha_log_dir		= $::koha::params::koha_log_dir,
	$koha_share_dir		= $::koha::params::koha_share_dir,
	$koha_spool_dir		= $::koha::params::koha_spool_dir
)
{
	##
	# Processed default parameters.
	##

	$_pluginsdir = pick($pluginsdir, "${koha_lib_dir}/${site_name}/plugins")

	$_intranetdir = pick($intranetdir, "${koha_share_dir}/intranet/cgi-bin")
	$_opacdir = pick($opacdir, "${koha_share_dir}/opac/cgi-bin/opac")
	$_opachtdocs = pick($opachtdocs, "${koha_share_dir}/opac/htdocs/opac-tmpl")
	$_intrahtdocs = pick($intrahtdocs, "${koha_share_dir}/intranet/htdocs/intranet-tmpl")
	$_includes = pick($includes, "${koha_share_dir}/intranet/htdocs/intranet-tmpl/prog/en/includes/")
	$_logdir = pick($logdir, "${koha_log_dir}/${site_name}")
	$_docdir = pick($docdir, $koha_doc_dir)
	$_backupdir = pick($backupdir, "${koha_spool_dir}/${site_name}")

	$_install_log = pick($install_log, "${koha_share_dir}/misc/koha-install-log")

	$_zebra_lockdir = pick($zebra_lockdir, "${koha_lock_dir}/${site_name}")
	$_queryparser_config = pick($queryparser_config, "${koha_config_dir}/searchengine/queryparser.yaml")
	$_log4perl_conf = pick($log4perl_conf, "${koha_config_dir}/log4perl.conf")

	::concat::fragment
	{ "${site_name}::koha_conf_xml::config_start":
		target	=> "${site_name}::koha_conf_xml",
		ensure	=> $ensure,
		content	=> "<config>\n",
		order	=> "05",
	}

	::concat::fragment
	{ "${site_name}::koha_conf_xml::config_main":
		target	=> "${site_name}::koha_conf_xml",
		ensure	=> $ensure,
		content	=> template("koha/koha_conf_xml/config_main.xml.erb"),
		order	=> "07",
	}

	::concat::fragment
	{ "${site_name}::koha_conf_xml::config_end":
		target	=> "${site_name}::koha_conf_xml",
		ensure	=> $ensure,
		content	=> "</config>\n",
		order	=> "08",
	}
}
