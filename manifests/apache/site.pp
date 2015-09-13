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
	$ensure					= "present",

	$site_name				= $name,
	$site_intra				= undef, # Defined in resource body
	$base_domain				= $::

	$site_file				= $name,

	$use_rewrite_log			= false,

	$ssl					= true,
	$ssl_only				= false,
	$opac_ssl				= undef, # Defined in resource body
	$intra_ssl				= undef, # Defined in resource body

	$port					= "80",
	$ssl_port				= "443",

	$opac_port				= undef, # Defined in resource body
	$opac_ssl_port				= undef, # Defined in resource body

	$intra_port				= undef, # Defined in resource body
	$intra_ssl_port				= undef, # Defined in resource body

	$opac_ssl_certificate_file		= $::koha::params::site_ssl_certificate_file,
	$opac_ssl_certificate_key_file		= $::koha::params::site_ssl_certificate_key_file,
	$opac_ssl_ca_certificate_path		= $::koha::params::site_ssl_ca_certificate_path,

	$intra_ssl_certificate_file		= $::koha::params::site_ssl_certificate_file,
	$intra_ssl_certificate_key_file		= $::koha::params::site_ssl_certificate_key_file,
	$intra_ssl_ca_certificate_path		= $::koha::params::site_ssl_ca_certificate_path,

	$opac_server_name			= undef, # Defined in resource body
	$intra_server_name			= undef, # Defined in resource body

	$opac_error_log				= undef, # Defined in resource body
	$opac_access_log			= undef, # Defined in resource body
	$opac_rewrite_log			= undef, # Defined in resource body

	$opac_error_ssl_log			= undef, # Defined in resource body
	$opac_access_ssl_log			= undef, # Defined in resource body
	$opac_rewrite_ssl_log			= undef, # Defined in resource body

	$intranet_error_log			= undef, # Defined in resource body
	$intranet_access_log			= undef, # Defined in resource body
	$intranet_rewrite_log			= undef, # Defined in resource body

	$intranet_error_ssl_log			= undef, # Defined in resource body
	$intranet_access_ssl_log		= undef, # Defined in resource body
	$intranet_rewrite_ssl_log		= undef, # Defined in resource body

	# koha::params default values.
	$apache_dir_owner			= $::koha::params::apache_dir_owner,
	$apache_dir_group			= $::koha::params::apache_dir_group,
	$apache_dir_mode			= $::koha::params::apache_dir_mode,
	$apache_config_dir			= $::koha::params::apache_config_dir,
	$apache_sites_available_dir		= $::koha::params::apache_sites_available_dir,
	$apache_sites_enabled_dir		= $::koha::params::apache_sites_enabled_dir,
	$apache_sites_dir_conf_file_owner	= $::koha::params::apache_sites_dir_conf_file_owner,
	$apache_sites_dir_conf_file_mode	= $::koha::params::apache_sites_dir_conf_file_mode,
	$koha_log_dir				= $::koha::params::koha_log_dir,
	$koha_site_dir				= $::koha::params::koha_site_dir
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

	#$koha_user = getparam(::Koha::User_name[$site_name], "user")
	$koha_user = "${site_name}-koha"
	#$koha_conf_xml = getparam(::Koha::Files::Koha_conf_xml_file[$site_name], "filename")
	$koha_conf_xml = "$koha_site_dir/$site_name/koha-conf.xml"

	$_site_intra = pick($site_intra, "$site_name-intra")

	$_opac_ssl = pick($opac_ssl, $ssl)
	$_intra_ssl = pick($intra_ssl, $ssl)

	$_opac_port = pick($opac_port, $port)
	$_opac_ssl_port = pick($opac_ssl_port, $ssl_port)

	$_intra_port = pick($intra_port, $port)
	$_intra_ssl_port = pick($intra_ssl_port, $ssl_port)

	$_opac_server_name = pick($opac_server_name, "${site_name}.${::domain}")
	$_intra_server_name = pick($intra_server_name, "${_site_intra}.${::domain}")

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
	# Required resources.
	##

	# Generate Apache vhosts for the OPAC and Intranet servers for this Koha site.

	##
	# Apache vhost configuration.
	##

	ensure_resource("apache::listen", $_opac_port)
	ensure_resource("apache::listen", $_opac_ssl_port)
	ensure_resource("apache::listen", $_intra_port)
	ensure_resource("apache::listen", $_intra_ssl_port)

	::concat
	{ "${site_name}::apache_site_conf":
		path	=> "$apache_sites_available_dir/$site_file.conf",
		ensure	=> $ensure,
		owner	=> $apache_sites_dir_conf_file_owner,
		group	=> $koha_user,
		mode	=> $apache_sites_dir_conf_file_mode,
		require	=> [ Class["::koha::install"], ::Koha::Site_resources[$site_name] ],
		before	=> Class["::koha::service"],
		notify	=> Class["::apache::service"],
	}

	::concat::fragment
	{ "${site_name}::apache_site_conf::main":
		target	=> "${site_name}::apache_site_conf",
		ensure	=> $ensure,
		content	=> template("koha/apache-site.conf.erb"),
		order	=> "00",
	}

	file
	{ "$apache_sites_enabled_dir/$site_file.conf":
		ensure	=> $link_ensure,
		target	=> "$apache_sites_available_dir/$site_file.conf",
		owner	=> $apache_sites_dir_conf_file_owner,
		group	=> $koha_user,
		mode	=> $apache_sites_dir_conf_file_mode,
		require	=> [ Class["::koha::install"], ::Koha::Site_resources[$site_name], ::Concat["${site_name}::apache_site_conf"] ],
		before	=> Class["::koha::service"],
		notify	=> Class["::apache::service"],
	}

	::koha::apache::site_name
	{ $site_name:
		site_intra		=> $site_intra,
		opac_server_name	=> $_opac_server_name,
		intra_server_name	=> $_intra_server_name,
	}
}
