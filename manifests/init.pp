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

	# Include other related resources used by other parts of the module.
	include ::koha::system_resources

	##
	# Defined resources.
	##
	unless (defined(Class["::koha::install"]))
	{
		class
		{ "::koha::install":
			ensure	=> $ensure,
		}
	}

	unless (defined(Class["::koha::service"]))
	{
		class
		{ "koha::service":
			ensure	=> $ensure,
		}
	}

	##
	# Dependency chains.
	##
	Class["::koha::install"] -> Class["::koha::system_resources"]
	Class["::koha::install"] -> Class["::koha::service"]
}
