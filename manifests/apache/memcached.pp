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
define koha::apache::memcached
(
	$ensure			= "present",
	$site_name		= $name,

	$memcached_port		= "11211",
	$memcached_namespace
)
{
	$opac_server_name = getparam(Koha::Apache::Site_name[$site_name], "opac_server_name")
	$intra_server_name = getparam(Koha::Apache::Site_name[$site_name], "intra_server_name")
	$memcached_servers = join(regsubst(query_nodes("Koha::Memcached::Site['$site_name']"), "^(.*)$", "\1:$memcached_port"), " ")

	::concat::fragment
	{ "${site_name}::apache_site_conf::memcached":
		target	=> "${site_name}::apache_site_conf",
		ensure	=> $ensure,
		content	=> template("koha/apache-site-memcached.conf.erb"),
		order	=> "01",
	}
}
