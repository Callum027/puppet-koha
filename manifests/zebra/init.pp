# == Class: koha::zebra
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
class koha::zebra
(
	$lang			= $koha::params::zebra_lang,
	$marc_format		= $koha::params::zebra_marc_format,
	$password		= undef,
	$biblios_config		= $koha::params::zebra_biblios_config,
	$authorities_config	= $koha::params::zebra_authorities_config
) inherits koha::params
{
	# Start the Koha zebra service, if it hasn't been already.
	# $ koha-start-zebra "$name"
	# $ koha-indexer --start "$name"
}
