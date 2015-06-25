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
define koha::files::koha_conf_xml_site
(
	$ensure					= "present",
	$site_name				= $name,

	$koha_configured			= false,
	$koha_zebra_configured			= false,

	# Global koha-conf.xml options.
	$koha_user,
	$koha_zebra_password,

	$koha_config_dir,
	$koha_site_dir,
	$koha_site_dir_conf_file_mode,
	$koha_lib_dir,
	$koha_log_dir,
	$koha_log_dir_mode,

	$koha_zebra_biblios_config,
	$koha_zebra_authorities_config,

	$koha_zebra_biblios_indexing_mode,
	$koha_zebra_authorities_indexing_mode,

	$koha_zebra_marc_format,

	$koha_zebra_server_biblios_port,
	$koha_zebra_server_authorities_port,

	$koha_zebra_biblioserver,
	$koha_zebra_authorityserver,

	# koha-conf.xml options specific to the koha::site class.
	$mysql_db				= undef,
	$mysql_hostname				= undef,
	$mysql_port				= undef,
	$mysql_user				= undef,
	$mysql_password				= undef,

	$koha_zebra_server			= undef,

	# koha-conf.xml options specific to the koha::zebra::site class.
	$public_z3950_server			= false,
	$koha_zebra_sru_hostname		= undef,

	$koha_zebra_sru_biblios_port		= undef,
	$koha_zebra_sru_authorities_port	= undef,

	$koha_zebra_sru_biblios_database	= undef,
	$koha_zebra_sru_authorities_database	= undef
)
{
	unless (defined(Class["::koha"]))
	{
		fail("You must define the Koha base class before using setting up a Koha site")
	}

	if ($koha_configured == true and $koha_zebra_configured != true and $koha_zebra_server != undef)
	{
		$_koha_zebra_biblioserver = "tcp:$koha_zebra_server:$koha_zebra_server_biblios_port/$koha_zebra_biblioserver"
		$_koha_zebra_authorityserver = "tcp:$koha_zebra_server:$koha_zebra_server_authorities_port/$koha_zebra_authorityserver"
	}
	else
	{
		$_koha_zebra_biblioserver = $koha_zebra_biblioserver
		$_koha_zebra_authorityserver = $koha_zebra_authorityserver
	}

	file
	{ "$koha_site_dir/$site_name/koha-conf.xml":
		ensure	=> $ensure,
		owner	=> "root",
		group	=> $_koha_user,
		mode	=> $koha_site_dir_conf_file_mode,
		content	=> template("koha/koha-conf-site.xml.erb"),
	}
}
