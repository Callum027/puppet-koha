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
define koha::files::koha_conf_xml
(
	$ensure		= "present",
	$site_name	= $name,

	$file,
	$owner		= $::koha::params::koha_conf_xml::file_owner,
	$group,
	$mode		= $::koha::params::koha_conf_xml::file_mode,

	# koha::params default values.
	$koha_site_dir	= $::koha::params::koha_site_dir
)
{
	##
	# Resource dependencies.
	##

	unless (defined(Class["::koha::params"]))
	{
		fail("You must define koha::params for this resource to work properly")
	}

	##
	# Resource declaration.
	##

	::concat
	{ "${site_name}::koha_conf_xml":
		path	=> $file,
		ensure	=> $ensure,
		owner	=> $owner,
		group	=> $group,
		mode	=> $mode,
	}

	::concat::fragment
	{ "${site_name}::koha_conf_xml::header":
		target	=> "${site_name}::koha_conf_xml",
		ensure	=> $ensure,
		content	=> "<yazgfs>\n<!-- This file is managed by Puppet. Any local modifications will be overwritten. -->\n\n",
		order	=> "00",
	}

	::concat::fragment
	{ "${site_name}::koha_conf_xml::footer":
		target	=> "${site_name}::koha_conf_xml",
		ensure	=> $ensure,
		content	=> "</yazgfs>\n",
		order	=> "99",
	}
}
