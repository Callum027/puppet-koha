# == Resource: koha::translate
#
# Install non-standard languages into Koha.
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
define koha::translate
(
	$ensure		= "present",
	$language_code	= $name,

	$grep		= undef,
	$koha_translate = undef
)
{
	# TODO: Proper dependency ordering for koha::params, to get rid of this $x_real BS.
	require ::koha::params

	if ($grep == undef)
	{
		$grep_real = $::koha::params::grep
	}
	else
	{
		$grep_real = $grep
	}

	if ($koha_translate == undef)
	{
		$koha_translate_real = $::koha::params::koha_translate
	}
	else
	{
		$koha_translate_real = $koha_translate
	}

	# This will fail if the given language code is not available.
	if ($ensure == "present")
	{
		exec
		{ "$koha_translate_real --install $language_code_real":
			require	=> Class["::koha"],
			onlyif	=> "$koha_translate_real --list --available | $grep_real -v $language_code_real",
		}
	}
	elsif ($ensure == "absent")
	{
		exec
		{ "$koha_translate_real --remove $language_code_real":
			require	=> Class["::koha"],
			onlyif	=> "$koha_translate_real --list --available | $grep_real $language_code_real",
		}
	}

	if ($ensure != "present" and $ensure != "absent")
	{
		fail("invalid value for ensure: $ensure")
	}
}
