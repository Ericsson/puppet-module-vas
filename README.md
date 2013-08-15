# puppet-module-vas

Puppet module to manage VAS - Quest Authentication Services

[![Build Status](https://api.travis-ci.org/Ericsson/puppet-module-vas.png?branch=master)](https://travis-ci.org/Ericsson/puppet-module-vas)

===

# Compatibility

This module has been tested to work on the following systems with Puppet v3.

 * EL 5
 * EL 6
 * SLES 10
 * SLES 11
 * Solaris 10
 * Ubuntu 12.04 LTS (Precise Pangolin)

===

# Parameters


package_version
---------------
- *Default*: 'UNSET'

users_allow_entries
-------------------
- *Default*: ['UNSET']

user_override_entries
---------------------
- *Default*: ['UNSET']

username
--------
- *Default*: 'username'

keytab_source
-------------
- *Default*: 'UNSET'

keytab_target
-------------
- *Default*: '/etc/vasinst.key'

computers_ou
------------
- *Default*: 'ou=computers,ou=example,ou=com'

users_ou
--------
- *Default*: 'ou=users,ou=example,ou=com'

nismaps_ou
----------
- *Default*: 'ou=nismaps,ou=example,ou=com'

realm
-----
- *Default*: 'realm.example.com'

sitenameoverride
----------------
- *Default*: 'UNSET'

vas_conf_update_process
-----------------------
- *Default*: '/opt/quest/libexec/vas/mapupdate_2307'

vas_conf_upm_computerou_attr
----------------------------
- *Default*: 'department'

vas_conf_client_addrs
---------------------
- *Default*: 'UNSET'

solaris_vasclntpath
-------------------
- *Default*: 'UNSET'

solaris_vasyppath
-----------------
- *Default*: 'UNSET'

solaris_vasgppath
-----------------
- *Default*: 'UNSET'

solaris_adminpath
-----------------
- *Default*: 'UNSET'

solaris_responsepattern
-----------------------
- *Default*: 'UNSET'
