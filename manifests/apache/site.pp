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

	$ssl				= $::koha::params::site_ssl,
	$ssl_only			= $::koha::params::site_ssl_only,
	$opac_ssl			= undef, # Defined in resource body
	$intra_ssl			= undef, # Defined in resource body

	$opac_port			= $::koha::params::site_opac_port,
	$opac_ssl_port			= $::koha::params::site_opac_ssl_port,

	$intra_port			= $::koha::params::site_intra_port,
	$intra_ssl_port			= $::koha::params::site_intra_ssl_port,

	$opac_ssl_certificate_file	= $::koha::params::site_ssl_certificate_file,
	$opac_ssl_certificate_key_file	= $::koha::params::site_ssl_certificate_key_file,
	$opac_ssl_ca_certificate_path	= $::koha::params::site_ssl_ca_certificate_path,

	$intra_ssl_certificate_file	= $::koha::params::site_ssl_certificate_file,
	$intra_ssl_certificate_key_file	= $::koha::params::site_ssl_certificate_key_file,
	$intra_ssl_ca_certificate_path	= $::koha::params::site_ssl_ca_certificate_path,

	$opac_server_name		= undef, # Defined in resource body
	$intra_server_name		= undef, # Defined in resource body

	$koha_conf,

	$collect_memcached,
	$memcached_servers		= undef,
	$memcached_namespace,

	$opac_error_log			= undef, # Defined in resource body
	$opac_access_log		= undef, # Defined in resource body
	$opac_rewrite_log		= undef, # Defined in resource body

	$opac_error_ssl_log		= undef, # Defined in resource body
	$opac_access_ssl_log		= undef, # Defined in resource body
	$opac_rewrite_ssl_log		= undef, # Defined in resource body

	$intranet_error_log		= undef, # Defined in resource body
	$intranet_access_log		= undef, # Defined in resource body
	$intranet_rewrite_log		= undef, # Defined in resource body

	$intranet_error_ssl_log		= undef, # Defined in resource body
	$intranet_access_ssl_log	= undef, # Defined in resource body
	$intranet_rewrite_ssl_log	= undef, # Defined in resource body

	# koha::params default values.
	$koha_site_dir			= $::koha::params::koha_site_dir,
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

	$_opac_ssl = pick($opac_ssl, $ssl)
	$_intra_ssl = pick($intra_ssl, $ssl)

	$_memcached_namespace = pick($memcached_namespace, "koha_${site_name}")

	if ($collect_memcached != true)
	{
		$memcached_servers_query = query_nodes('Koha::Site::Memcached["$_memcached_namespace"]')
	}

	if (is_array($memcached_servers))
	{
		$_memcached_servers = join($memcached_servers, ",")
	}
	elsif (is_string($memcached_servers))
	{
		$_memcached_servers = $memcached_servers
	}
	elsif ($memcached_servers_query != undef)
	{
		$_memcached_servers = join($memcached_servers_query, ",")
	}
	else
	{
		$_memcached_servers = ""
	}

	$_opac_server_name = pick($opac_server_name, "${site_name}.${::domain}")
	$_intra_server_name = pick($intra_server_name, "${_site_intra}.${::domain}")

	# Apache log files.
	$_opac_error_log = pick($opac_error_log, "${koha_log_dir}/${site_name}/opac-error.log")
	$_opac_access_log = pick($opac_access_log, "${koha_log_dir}/${site_name}/opac-access.log")
	$_opac_rewrite_log = pick($opac_rewrite_log, "${koha_log_dir}/${site_name}/opac-rewrite.log")

	$_opac_error_ssl_log = pick($opac_error_ssl_log, "${koha_log_dir}/${site_name}/opac-error-ssl.log")
	$_opac_access_ssl_log = pick($opac_access_ssl_log, "${koha_log_dir}/${site_name}/opac-access-ssl.log")
	$_opac_rewrite_ssl_log = pick($opac_rewrite_ssl_log, "${koha_log_dir}/${site_name}/opac-rewrite-ssl.log")


	$_intranet_error_log = pick($intranet_error_log, "${koha_log_dir}/${site_name}/intranet-error.log")
	$_intranet_access_log = pick($intranet_access_log, "${koha_log_dir}/${site_name}/intranet-access.log")
	$_intranet_rewrite_log = pick($intranet_rewrite_log, "${koha_log_dir}/${site_name}/intranet-rewrite.log")

	$_intranet_error_ssl_log = pick($intranet_error_ssl_log, "${koha_log_dir}/${site_name}/intranet-error-ssl.log")
	$_intranet_access_ssl_log = pick($intranet_access_ssl_log, "${koha_log_dir}/${site_name}/intranet-access-ssl.log")
	$_intranet_rewrite_ssl_log = pick($intranet_rewrite_ssl_log, "${koha_log_dir}/${site_name}/intranet-rewrite-ssl.log")


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

	ensure_resource("apache::listen", $opac_port)
	ensure_resource("apache::listen", $opac_ssl_port)
	ensure_resource("apache::listen", $intra_port)
	ensure_resource("apache::listen", $intra_ssl_port)

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
