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
define koha::files::koha_conf_xml::config_index_mode
(
	$ensure			= "present",
	$site_name,
	$id,

	$zebra_bib_index_mode	= undef, # Filled in by ::koha::site::zebra
	$zebra_auth_index_mode	= undef  # Filled in by ::koha::site::zebra
)
{
	if ($zebra_bib_index_mode != undef)
	{
		::concat::fragment
		{ "${site_name}::koha_conf_xml::config_zebra_bib_index_mode":
			target	=> "${site_name}::koha_conf_xml",
			ensure	=> $ensure,
			content	=> " <zebra_bib_index_mode>$zebra_bib_index_mode</zebra_bib_index_mode>\n",
			order	=> "06",
		}
	}

	if ($zebra_auth_index_mode != undef)
	{
		::concat::fragment
		{ "${site_name}::koha_conf_xml::config_zebra_auth_index_mode":
			target	=> "${site_name}::koha_conf_xml",
			ensure	=> $ensure,
			content	=> " <zebra_auth_index_mode>$zebra_auth_index_mode</zebra_auth_index_mode>\n",
			order	=> "06",
			order	=> "06",
		}
	}
}
