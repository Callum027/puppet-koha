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
	if (Class["koha::install"] != undef)
	{	
		require koha::install
	}

	if (Class["koha::service"] != undef)
	{
		require koha::service
	}
}
