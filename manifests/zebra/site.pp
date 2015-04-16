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
define koha::zebra::site
(
	$ensure			= present,

	$site_name		= $name,
	$site_user		= "$site_name-koha",
	$password		= undef,

	$koha_site_dir		= $koha::params::koha_site_dir,
	$koha_language		= $koha::params::koha_language,
	$marc_format		= $koha::params::koha_marc_format,
	$biblios_config		= $koha::params::koha_zebra_biblios_config,
	$authorities_config	= $koha::params::koha_zebra_authorities_config,

	$koha_zebra_services	= $koha::params::koha_zebra_services,

	$pwgen			= $koha::params::pwgen,
	$sed			= $koha::params::sed,
	$test			= $koha::params::test
) inherits koha::params
{
	# If a password wasn't passed into the resource, automatically generate it.
	if ($password == undef)
	{
		$password = generate("$pwgen -s 16 1")
	}

	# Generate and install Zebra config files.
	file
	{ "$koha_site_dir/$site_name/zebra-biblios.cfg":
		ensure	=> $ensure,
		owner	=> root,
		group	=> $site_user,
		mode	=> 640,
		content	=> template("koha/zebra-biblios.cfg.erb"),
		notify	=> Service[$koha_zebra_services],
	}

	file
	{ "$koha_site_dir/$site_name/zebra-biblios-dom-site.cfg":
		ensure	=> $ensure,
		owner	=> root,
		group	=> $site_user,
		mode	=> 640,
		content	=> template("koha/zebra-biblios-dom-site.cfg.erb"),
		notify	=> Service[$koha_zebra_services],
	}

	file
	{ "$koha_site_dir/$site_name/zebra-authorities-site.cfg":
		ensure	=> $ensure,
		owner	=> root,
		group	=> $site_user,
		mode	=> 640,
		content	=> template("koha/zebra-authorities-site.cfg.erb"),
		notify	=> Service[$koha_zebra_services],
	}

	file
	{ "$koha_site_dir/$site_name/zebra-authorities-dom-site.cfg":
		ensure	=> $ensure,
		owner	=> root,
		group	=> $site_user,
		mode	=> 640,
		content	=> template("koha/zebra-authorities-dom-site.cfg.erb"),
		notify	=> Service[$koha_zebra_services],
	}

	file
	{ "$koha_site_dir/$site_name/zebra.passwd":
		ensure	=> $ensure,
		owner	=> root,
		group	=> $site_user,
		mode	=> 640,
		content	=> template("koha/zebra.passwd.erb"),
		unless	=> "$test \$($sed 's/^kohauser:.*/pass/' $koha_site_dir/$site_name/zebra.passwd) = 'pass'",
		notify	=> Service[$koha_zebra_services],
	}
}
