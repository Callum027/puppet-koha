# == Class: koha::params::koha_conf_xml
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
class koha::params::koha_conf_xml
{
	# File options.
	$file_owner				= $::koha::params::koha_site_dir_conf_file_owner
	$file_mode				= $::koha::params::koha_site_dir_conf_file_mode

	# Global default options.
	$default_biblios_indexing_mode		= "dom"
	$default_authorities_indexing_mode	= "dom"

	# Server-specific options.
	$biblioserver_id			= "biblioserver"
	$biblioserver_sru_explain		= "${::koha::params::koha_config_dir}/zebradb/explain-biblios.xml"
	$biblioserver_sru_port			= "9998"

	$authorityserver_id			= "authorityserver"
	$authorityserver_sru_explain		= "${::koha::params::koha_config_dir}/zebradb/explain-authorities.xml"
	$authorityserver_sru_port		= "9999"

	$publicserver_id			= "publicserver"
	$publicserver_socket			= "tcp:@:${publicserver_sru_port}"
	$publicserver_sru_explain		= $biblioserver_sru_explain
	$publicserver_sru_port			= "210"

	$mergeserver_id				= "mergeserver"
	$mergeserver_cql2rpn			= "${::koha::params::koha_lib_dir}/zebradb/pqf.properties"
	$mergeserver_socket			= "tcp:@:${mergeserver_port}"

	# Config options.
	$config_db_scheme			= "mysql"
	$config_port_mysql			= "3306"
	$config_port_postgresql			= "5432"

	$config_biblioserver			= "biblios"
	$config_biblioservershadow		= 1

	$config_authorityserver			= "authorities"
	$config_authorityservershadow		= 1

	$config_enable_plugins			= 0

	$config_intranetdir 			= "${::koha::params::koha_share_dir}/intranet/cgi-bin"
	$config_opacdir				= "${::koha::params::koha_share_dir}/opac/cgi-bin/opac"
	$config_opachtdocs			= "${::koha::params::koha_share_dir}/opac/htdocs/opac-tmpl"
	$config_intrahtdocs			= "${::koha::params::koha_share_dir}/intranet/htdocs/intranet-tmpl"
	$config_includes			= "${::koha::params::koha_share_dir}/intranet/htdocs/intranet-tmpl/prog/en/includes/"
	$config_docdir				= "${::koha::params::koha_doc_dir}"

	$config_backup_db_via_tools		= 0
	$config_backup_conf_via_tools		= 0

	$config_install_log			= "${::koha::params::koha_share_dir}/misc/koha-install-log"

	$config_useldapserver			= 0
	$config_useshibboleth			= 0

	$config_zebra_bib_index_mode		= $default_biblios_indexing_mode
	$config_zebra_auth_index_mode		= $default_authorities_indexing_mode

	$config_use_zebra_facets		= 1

	$config_queryparser_config		= "${::koha::params::koha_config_dir}/searchengine/queryparser.yaml"

	# Listen options.
	

	# Server options.
	$server_cql2rpn				= "${::koha::params::koha_config_dir}/zebradb/pqf.properties"

	$server_include_retrieval_info		= true

	$server_indexing_mode			= "dom"
	$server_marc_format			= "marc21"

	$server_remote_sru_server		= false

	# Serverinfo options.
	$serverinfo_ccl2rpn			= "${::koha::params::koha_config_dir}/zebradb/ccl.properties"
	$serverinfo_user			= $::koha::params::zebra_user
}
