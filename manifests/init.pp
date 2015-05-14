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
class koha
{
	unless ((defined(Class["koha::install"])))
	{	
		require koha::install
	}

	unless ((defined(Class["koha::service"])))
	{
		require koha::service
	}
}
