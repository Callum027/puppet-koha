# == Class: koha
#
# Full description of class koha here.
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
class koha
(
	$a2dismod		= $koha::params::a2dismod,
	$a2enmod		= $koha::params::a2enmod,

	$apache_a2dismod	= $koha::params::apache_a2dismod,
	$apache_a2enmod		= $koha::params::apache_a2enmod,
	$apache_packages	= $koha::params::apache_packages,
	$apache_service		= $koha::params::apache_service,

	$koha_packages		= $koha::params::koha_packages,
	$koha_service		= $koha::params::koha_service,
) inherits koha::params
{
	require koha::install
}
