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
define koha::files::koha_conf_xml::elasticsearch
(
	$ensure		= "present",
	$site_name,

	# Elasticsearch options.
	$server,
	$index_name
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

	validate_string($site_name, $id, $index_name)

	if (is_array($server) != true)
	{
		validate_string($server)
	}

	::concat::fragment
	{ "${site_name}::koha_conf_xml::elasticsearch_server::${server}":
		target	=> "${site_name}::koha_conf_xml",
		ensure	=> $ensure,
		content	=> " <server>$server</server>\n",
		order	=> "05",
	}
}
