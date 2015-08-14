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
define koha::apache::site
(
	$ensure				= "present",

	$site_name			= $name,
	$site_intra			= undef, # Defined in resource body

	$koha_user,

	$opac_port			= $::koha::params::site_opac_port,
	$intra_port			= $::koha::params::site_intra_port,

	$opac_server_name		= undef, # Defined in resource body
	$intra_server_name		= undef, # Defined in resource body

	$koha_conf,
	$memcached_server,
	$memcached_namespace,

	$opac_error_log			= undef, # Defined in resource body
	$opac_access_log		= undef, # Defined in resource body
	$opac_rewrite_log		= undef, # Defined in resource body

	$intranet_error_log		= undef, # Defined in resource body
	$intranet_access_log		= undef, # Defined in resource body
	$intranet_rewrite_log		= undef, # Defined in resource body

	# koha::params default values.
	$apache_sites_available_dir	= $::koha::params::apache_sites_available_dir,
	$apache_sites_enabled_dir	= $::koha::params::apache_sites_enabled_dir
)
{
	##
	# Resource dependencies.
	##

	unless (defined(Class["::koha"]))
	{
		fail("You must define the Koha base class before using setting up a Koha site")
	}

	##
	# Set default values.
	##

	$_site_intra = pick($site_intra, "$site_name-intra")

	$_mysql_db = pick($mysql_db, "koha_$site_name")
	$_mysql_user = pick($mysql_user, $_mysql_db)

	if (is_array($memcached_servers))
	{
		$_memcached_servers = join($memcached_servers, ",")
	}
	elsif (is_string($memcached_servers))
	{
		$_memcached_servers = $memcached_servers
	}
	else
	{
		$_memcached_servers = ""
	}

	$_memcached_namespace = pick($memcached_namespace, "koha_${site_name}")

	$_opac_server_name = pick($opac_server_name, "${site_name}.${::domain}")
	$_intra_server_name = pick($intra_server_name, "${_site_intra}.${::domain}")

	# Apache log files.
	$_opac_error_log = pick($opac_error_log, "${koha_log_dir}/${site_name}/opac-error.log")
	$_opac_access_log = pick($opac_access_log, "${koha_log_dir}/${site_name}/opac-access.log")
	$_opac_rewrite_log = pick($opac_rewrite_log, "${koha_log_dir}/${site_name}/opac-rewrite.log")

	$_intranet_error_log = pick($intranet_error_log, "${koha_log_dir}/${site_name}/intranet-error.log")
	$_intranet_access_log = pick($intranet_access_log, "${koha_log_dir}/${site_name}/intranet-access.log")
	$_intranet_rewrite_log = pick($intranet_rewrite_log, "${koha_log_dir}/${site_name}/intranet-rewrite.log")


	if ($ensure == "present")
	{
		$directory_ensure	= "directory"
		$link_ensure		= "link"
	}
	else
	{
		$directory_ensure	= $ensure
		$link_ensure		= $ensure
	}

	##
	# Argument sanity checks.
	##

	if ($ensure != "present" and $ensure != "absent")
	{
		fail("invalid value for ensure: $ensure")
	}

	##
	# Resource declaration.
	##

	unless (defined(::Apache::Listen[$opac_port]))
	{
		::apache::listen { $opac_port: }
	}

	unless (defined(::Apache::Listen[$intra_port]))
	{
		::apache::listen { $intra_port: }
	}

	# Generate Apache vhosts for the OPAC and Intranet servers for this Koha site.
	file
	{ "$apache_sites_available_dir/$site_name.conf":
		ensure	=> $ensure,
		owner	=> $apache_sites_dir_conf_file_owner,
		group	=> $koha_user,
		mode	=> $apache_sites_dir_conf_file_mode,
		content	=> template("koha/apache-site.conf.erb"),
		require	=> [ Class["::koha"], File["$koha_site_dir/$site_name"], ::Koha::User[$koha_user] ],
		before	=> Class["::koha::service"],
		notify	=> Class["::apache::service"],
	}

	file
	{ "$apache_sites_enabled_dir/$site_name.conf":
		ensure	=> $link_ensure,
		target	=> "$apache_sites_available_dir/$site_name.conf",
		owner	=> $apache_sites_dir_conf_file_owner,
		group	=> $koha_user,
		mode	=> $apache_sites_dir_conf_file_mode,
		require	=> [ Class["::koha"], File[["$koha_site_dir/$site_name", "$apache_sites_available_dir/$site_name.conf"]], ::Koha::User[$koha_user] ],
		before	=> Class["::koha::service"],
		notify	=> Class["::apache::service"],
	}
}
