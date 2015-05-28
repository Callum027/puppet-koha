# == Class: koha::install
#
# Installation of required packages for Koha, including Apache.
# Also takes care of Apache module configuration, as this is required for
# Koha to be properly installed from the packages.
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
class koha::install
(
	$ensure			= "present",

	$apache_modules_dir	= $::koha::params::apache_modules_dir,
	$apache_modules_user	= $::koha::params::apache_modules_user,
	$apache_modules_group	= $::koha::params::apache_modules_group,
	$apache_modules_mode	= $::koha::params::apache_modules_mode,

	$koha_packages		= $::koha::params::koha_packages
) inherits koha::params
{
	# Install the Koha repository.
	unless (defined(Class["::koha::repo"]))
	{
		class
		{ "koha::repo":
			ensure	=> $ensure,
		}

		contain "::koha::repo"
	}

	# A MySQL client is required for Koha to access the library databases.
	unless ($ensure != "present" or defined(Class["::mysql::client"]))
	{
		contain ::mysql::client
	}

	# Install Apache, the web server that Koha uses.
	if ($ensure == "present")
	{
		class
		{ "::apache":
			mpm_module	=> "itk",
		}

		contain "::apache"

		::apache::mod { "cgi": }
		contain ::apache::mod::rewrite
	}

	# Get around a bug in the Ubuntu Apache packages where the symbolic object
	# for the ITK MPM module is named incorrectly, by making a symbolic link
	# to mpm_itk.so from mod_mpm_itk.so.
	if ($ensure == "present")
	{
		$link_ensure		= "link"
	}
	else
	{
		$link_ensure		= $ensure
	}

	file
	{ "$apache_modules_dir/mod_mpm_itk.so":
		ensure	=> $link_ensure,
		target	=> "$apache_modules_dir/mpm_itk.so",
		user	=> $apache_modules_user,
		group	=> $apache_modules_group,
		mode	=> $apache_modules_mode,
		onlyif	=> "$test -f $apache_modules_dir/mpm_itk.so",
		notify	=> Class["::apache"],
	}

	# Install packages.
	if ($ensure == "present")
	{
		package
		{ $koha_packages:
			ensure	=> "installed",
			require	=> Class[[ "::koha::repo", "::apache" ]],
		}
	}
	elsif ($ensure == "absent")
	{
		package
		{ $koha_packages:
			ensure	=> "purged",
			require	=> Class["::koha::repo"],
		}
	}
	else
	{
		fail("invalid value for ensure: $ensure")
	}
}
