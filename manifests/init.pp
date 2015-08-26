# == Class: koha
#
# Metaclass for the koha::install class.
#
# === Parameters
#
#
# === Variables
#
#
# === Examples
#
#  include koha
#
# === Authors
#
# Callum Dickinson <callum@huttradio.co.nz>
#
# === Copyright
#
# Copyright 2015 Callum Dickinson.
#
class koha($ensure = "present")
{
	require ::koha::params
	require ::koha::params::koha_conf_xml

	unless (defined(Class["::koha::install"]))
	{	
		class
		{ "::koha::install":
			ensure	=> $ensure,
		}

		contain "::koha::install"
	}
}
