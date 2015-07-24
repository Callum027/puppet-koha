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
define koha::files::koha_conf_xml::server
(
	$ensure		= "present",
	$site_name,

	# Server options.
	$id,

	$directory		= undef, # Defined in resource body
	$config,
	$cql2rpn		= $::koha::params::koha_conf_xml::server_cql2rpn,

	$include_retrieval_info	= $::koha::params::koha_conf_xml::server_include_retrieval_info,

	$dom_retrieval_info	= undef, # Required for include_retrieval_info == true and indexing_mode == "dom"

	$indexing_mode		= $::koha::params::koha_conf_xml::server_indexing_mode,
	$marc_format		= $::koha::params::koha_conf_xml::server_marc_format,

	$public_sru_server	= $::koha::params::koha_conf_xml::server_public_sru_server,

	$sru_explain		= undef,
	$sru_host		= undef,
	$sru_port		= undef,
	$sru_database		= undef,

	# koha::params default values.
	$koha_lib_dir		= $::koha::params::koha_lib_dir
)
{
	unless (defined(::Koha::Files::Koha_conf_xml[$site_name]))
	{
		fail("You must define the koha::files::koha_conf_xml resource for $site_name for this resource to work properly")
	}

	# Check validity of parameters.
	if ($ensure != "present" and $ensure != "absent")
	{
		fail("Only possible values for \$ensure are 'present' and 'absent'")
	}

	if ($directory == undef)
	{
		$_directory = "$koha_lib_dir/$site_name/$id"
	}
	else
	{
		$_directory = $directory
	}

	if ($include_retrieval_info == true and $indexing_mode == undef)
	{
		fail("No indexing mode set even though including retrieval information is enabled")
	}

	if ($include_retrieval_info == true and $marc_format == undef)
	{
		fail("No MARC format set even though including retrieval information is enabled")
	}

	if ($include_retrieval_info == true and $indexing_mode == "dom" and $dom_retrieval_info == undef)
	{
		fail("Need to set a retrieval information file if the indexing mode is 'dom'")
	}

	::concat::fragment
	{ "${site_name}::koha_conf_xml::server::${id}":
		target	=> "${site_name}::koha_conf_xml",
		ensure	=> $ensure,
		content	=> template("koha/koha_conf_xml/server.xml.erb"),
		order	=> "02",
	}
}
