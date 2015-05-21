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
	unless (defined("koha::install"))
	{	
		class
		{ "koha::install":
			ensure	=> $ensure,
		}

		contain "koha::install"
	}

	unless (defined("koha::service"))
	{	
		class
		{ "koha::service":
			ensure	=> $ensure,
		}

		contain "koha::service"
	}
}
