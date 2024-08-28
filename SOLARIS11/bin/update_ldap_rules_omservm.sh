#!/bin/bash

# Added a check for LDAP path.
if pgrep ns-slapd > /dev/null; then
	cd /ericsson/sdee/ldap_domain_settings
else
	cd /ericsson/opendj/ldap_domain_settings
fi

# Change min pwd length global
mv globaldomain.settings old.globaldomain.settings
sed  's/LDAP_MIN_PWD_LEN=8/LDAP_MIN_PWD_LEN=3/g' old.globaldomain.settings > globaldomain.settings

cd /ericsson/ocs/lib

# Change max uid
mv commonfun_ldap.lib old.commonfun_ldap.lib
sed  's/MOSS_MAX_UID=59999/MOSS_MAX_UID=200000/g' old.commonfun_ldap.lib > commonfun_ldap.lib

# Change min uid
mv commonfun_ldap.lib old.commonfun_ldap.lib
sed  's/MOSS_MIN_UID=1000/MOSS_MIN_UID=100/g' old.commonfun_ldap.lib > commonfun_ldap.lib

# Change min password length
mv commonfun_ldap.lib old.commonfun_ldap.lib
sed  's/local min_pwd_length=\$2/local min_pwd_length=3/g' old.commonfun_ldap.lib > commonfun_ldap.lib

# Allow underscores
mv commonfun_ldap.lib old.commonfun_ldap.lib
sed  's/a-zA-Z0-9]/a-zA-Z0-9_]/g' old.commonfun_ldap.lib > commonfun_ldap.lib

