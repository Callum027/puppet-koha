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
define koha::files::koha_conf_xml::biblioserver
(
	$ensure			= "present",
	$site_name		= $name,

	$password,

	# Server options.
	$id			= "biblioserver",

	$directory		= undef,
	$config			= undef, # Defined in resource body
	$cql2rpn		= undef, # Default defined in koha::files::koha_conf_xml::server

	$include_retrieval_info	= undef, # Default defined in koha::files::koha_conf_xml::server

	$dom_retrieval_info	= undef, # Defined in resource body

	$indexing_mode		= undef, # Default defined in koha::files::koha_conf_xml::server
	$marc_format		= undef, # Default defined in koha::files::koha_conf_xml::server

	$public_sru_server	= false,

	$sru_explain		= undef, # Defined in resource body
	$sru_host		= undef,
	$sru_port		= "9998",
	$sru_database		= $::koha::params::koha_conf_xml::config_biblioserver,

	# koha::params default values.
	$koha_config_dir	= $::koha::params::koha_config_dir,
	$koha_lib_dir		= $::koha::params::koha_lib_dir,
	$koha_site_dir		= $::koha::params::koha_site_dir
)
{
	##
	# Resource dependencies.
	##
	unless (defined(::Koha::Files::Koha_conf_xml[$site_name]))
	{
		fail("You must define the koha::files::koha_conf_xml resource for $site_name for this resource to work properly")
	}

	##
	# Default configuration values.
	##
	case $indexing_mode
	{
		"dom":	{ $_config = "${koha_site_dir}/${site_name}/zebra-biblios-dom.cfg" }
		"grs1":	{ $_config = "${koha_site_dir}/${site_name}/zebra-biblios.cfg" }
		default: { fail("invalid indexing mode for bibliographic records '$indexing_mode'") }
	}

	$_dom_retrieval_info = pick($dom_retrieval_info, "${koha_config_dir}/${marc_format}-retrieval-info-bib-dom.xml")
	$_sru_explain = pick($sru_explain, "${koha_config_dir}/zebradb/explain-biblios.xml")

	##
	# Parameter validation.
	##
	if ($ensure != "present" and $ensure != "absent")
	{
		fail("Only possible values for \$ensure are 'present' and 'absent'")
	}

	##
	# Defined resources.
	##
	::koha::files::koha_conf_xml::server
	{ "$site_name-$id":
		site_name		=> $site_name,
		id			=> $id,

		directory		=> $directory,
		config			=> $_config,
		cql2rpn			=> $cql2rpn,

		include_retrieval_info	=> $include_retrieval_info,

		dom_retrieval_info	=> $_dom_retrieval_info,

		indexing_mode		=> $indexing_mode,
		marc_format		=> $marc_format,

		public_sru_server	=> $public_sru_server,

		sru_explain		=> $_sru_explain,
		sru_host		=> $sru_host,
		sru_port		=> $sru_port,
		sru_database		=> $sru_database,
	}

	::koha::files::koha_conf_xml::serverinfo
	{
		password	=> $password,
	}
}
