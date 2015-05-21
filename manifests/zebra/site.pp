# == Class: koha::zebra::site
#
# Add a site to the Zebra indexer.
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
define koha::zebra::site
(
	$ensure				= present,

	$site_name			= $name,

	$koha_user			= undef,
	$zebra_password,

	$koha_site_dir			= undef,
	$koha_language			= undef,
	$koha_marc_format		= undef,
	$koha_zebra_biblios_config	= undef,
	$koha_zebra_authorities_config	= undef,

	$pwgen				= undef,
	$sed				= undef,
	$test				= undef
)
{
	unless (defined("koha::zebra"))
	{
		fail("You must include the koha::zebra base class before setting up a Koha Zebra site index")
	}

	# Require the params class, and set up the Koha Zebra service if it hasn't already.
	# TODO: Proper dependency ordering for koha::params, to get rid of this $x_real BS.
	require koha::params
	include koha::zebra::service

	# Parameters from koha::params.
	if ($koha_user == undef)
	{
		$koha_user_real = "$site_name-koha"
	}
	else
	{
		$koha_user_real = $koha_user
	}

	if ($koha_site_dir == undef)
	{
		$koha_site_dir_real = $koha::params::koha_site_dir
	}
	else
	{
		$koha_site_dir_real = $koha_site_dir
	}

	if ($koha_language == undef)
	{
		$koha_language_real = $koha::params::koha_language
	}
	else
	{
		$koha_language_real = $koha_language
	}

	if ($koha_marc_format == undef)
	{
		$koha_marc_format_real = $koha::params::koha_marc_format
	}
	else
	{
		$koha_marc_format_real = $koha_marc_format
	}

	if ($koha_zebra_biblios_config == undef)
	{
		$koha_zebra_biblios_config_real = $koha::params::koha_zebra_biblios_config
	}
	else
	{
		$koha_zebra_biblios_config_real = $koha_zebra_biblios_config
	}

	if ($koha_zebra_authorities_config == undef)
	{
		$koha_zebra_authorities_config_real = $koha::params::koha_zebra_authorities_config
	}
	else
	{
		$koha_zebra_authorities_config_real = $koha_zebra_authorities_config
	}

	if ($koha_zebra_services == undef)
	{
		$koha_zebra_services_real = $koha::params::koha_zebra_services
	}
	else
	{
		$koha_zebra_services_real = $koha_zebra_services
	}

	if ($pwgen == undef)
	{
		$pwgen_real = $koha::params::pwgen
	}
	else
	{
		$pwgen_real = $pwgen
	}

	if ($sed == undef)
	{
		$sed_real = $koha::params::sed
	}
	else
	{
		$sed_real = $sed
	}

	if ($test == undef)
	{
		$test_real = $koha::params::test
	}
	else
	{
		$test_real = $test
	}

	# Generate and install Zebra config files.
	file
	{ "$koha_site_dir/$site_name/zebra-biblios.cfg":
		ensure	=> $ensure,
		owner	=> root,
		group	=> $koha_user_real,
		mode	=> 640,
		content	=> template("koha/zebra-biblios.cfg.erb"),
		require	=> Class["koha::zebra"],
		notify	=> Class["koha::zebra::service"],
	}

	file
	{ "$koha_site_dir/$site_name/zebra-biblios-dom-site.cfg":
		ensure	=> $ensure,
		owner	=> root,
		group	=> $koha_user_real,
		mode	=> 640,
		content	=> template("koha/zebra-biblios-dom-site.cfg.erb"),
		require	=> Class["koha::zebra"],
		notify	=> Class["koha::zebra::service"],
	}

	file
	{ "$koha_site_dir/$site_name/zebra-authorities-site.cfg":
		ensure	=> $ensure,
		owner	=> root,
		group	=> $koha_user_real,
		mode	=> 640,
		content	=> template("koha/zebra-authorities-site.cfg.erb"),
		require	=> Class["koha::zebra"],
		notify	=> Class["koha::zebra::service"],
	}

	file
	{ "$koha_site_dir/$site_name/zebra-authorities-dom-site.cfg":
		ensure	=> $ensure,
		owner	=> root,
		group	=> $koha_user_real,
		mode	=> 640,
		content	=> template("koha/zebra-authorities-dom-site.cfg.erb"),
		require	=> Class["koha::zebra"],
		notify	=> Class["koha::zebra::service"],
	}

	file
	{ "$koha_site_dir/$site_name/zebra.passwd":
		ensure	=> $ensure,
		owner	=> root,
		group	=> $koha_user_real,
		mode	=> 640,
		content	=> template("koha/zebra.passwd.erb"),
		require	=> Class["koha::zebra"],
		notify	=> Class["koha::zebra::service"],
	}

	# Start the Koha zebra service, if it hasn't been already.
	# $ koha-start-zebra "$name"
	# $ koha-indexer --start "$name"
}
