# puppet-module-vas

Puppet module to manage VAS - Quest Authentication Services

[![Build Status](https://api.travis-ci.org/Ericsson/puppet-module-vas.png?branch=master)](https://travis-ci.org/Ericsson/puppet-module-vas)

===

# Compatibility

This module has been tested to work on the following systems using Puppet v3 and Ruby 1.8.7

 * EL 5
 * EL 6
 * Solaris 10

When using the users.allow functionality in VAS, make sure to set the following option:

<pre>
---
pam::allowed_users:
  - 'ALL'
</pre>
===

# Parameters


package_version
---------------
*Linux only* The VAS package version. Used when upgrading.

- *Default*: 'UNSET'

users_allow_entries
-------------------
List of users.allow entries. All users are allowed by default.

- *Default*: ['UNSET']

user_override_entries
---------------------
List of user-override entries. Used to override specific user data fields; UID, GID, GECOS, HOME_DIR and SHELL.

- *Default*: ['UNSET']

username
--------
Name of user account used to join Active Directory.

- *Default*: 'username'

keytab_path
-------------
The path to the keytab file used together with <username> to join Active Directoy.

- *Default*: '/etc/vasinst.key'

keytab_owner
------------
keytab file's owner.

- *Default*: 'root'

keytab_group
------------
keytab file's group.

- *Default*: 'root'

keytab_mode
-----------
keytab file's mode.
- *Default*: '0400'

computers_ou
------------
Path to OU where to store computer object.

- *Default*: 'ou=computers,dc=example,dc=com'

users_ou
--------
Path to OU where to load users initially.

- *Default*: 'ou=users,dc=example,dc=com'

nismaps_ou
----------
Path to OU where to load nismaps initially.

- *Default*: 'ou=nismaps,dc=example,dc=com'

realm
-----
Name of the realm.

- *Default*: 'realm.example.com'

nisdomainname
-------------
Name of the NIS domain.

- *Default*: undef

sitenameoverride
----------------
Name of AD site to join. The AD site is determined automatically in AD by default.

- *Default*: 'UNSET'

vas_conf_client_addrs
---------------------
client-addrs option in vas.conf. See VAS.CONF(5) for more info.

- *Default*: 'UNSET'

vas_conf_preload_nested_memberships
-----------------------------------
preload-nested-membership option in vas.conf. Set this to 'false' to speed up
flush (and join) operations in VAS version 4.0.3-206 and later.

- *Default*: 'UNSET' (keep default value from VAS)

vas_conf_update_process
-----------------------
update-process option in vas.conf. See VAS.CONF(5) for more info.

- *Default*: '/opt/quest/libexec/vas/mapupdate_2307'

vas_conf_upm_computerou_attr
----------------------------
upm-computerou-attr option in vas.conf. Changed to 'department' to work in a multi-AD-domain setup. See VAS.CONF(5) for more info.

- *Default*: 'department'

vas_config_path
---------------
Path to VAS config file.

- *Default*: '/etc/opt/quest/vas/vas.conf'

vas_config_owner
----------------
vas.conf's owner.

- *Default*: 'root'

vas_config_group
----------------
vas.conf's group.

- *Default*: 'root'

vas_config_mode
---------------
vas.conf's mode.

- *Default*: '0644'

vas_user_override_path
----------------------
Path to user-override file.

- *Default*: '/etc/opt/quest/vas/user-override'

vas_user_override_owner
-----------------------
user-override's owner.

- *Default*: 'root'

vas_user_override_group
-----------------------
user-override's group.

- *Default*: 'root'

vas_user_override_mode
----------------------
user-override's mode.

- *Default*: '0644'

vas_users_allow_path
--------------------
Path to users.allow file.

- *Default*: '/etc/opt/quest/vas/users.allow'

vas_users_allow_owner
---------------------
users.allow's owner.

- *Default*: 'root'

vas_users_allow_group
---------------------
users.allow's group.

- *Default*: 'root'

vas_users_allow_mode
--------------------
users.allow's mode.

- *Default*: '0644'

vasjoin_logfile
---------------
Path to logfile used by AD join commando.

- *Default*: '/var/tmp/vasjoin.log'

vaskeytab_package_name
----------------------
Name of vaskeytab package.

- *Default*: 'vaskeytab'

solaris_vasclntpath
-------------------
*Solaris only* Path to Solaris vasclnt package.

- *Default*: 'UNSET'

solaris_vasyppath
-----------------
*Solaris only* Path to Solaris vasyp package.

- *Default*: 'UNSET'

solaris_vasgppath
-----------------
*Solaris only* Path to Solaris vasgp package.

- *Default*: 'UNSET'

solaris_vaskeytabpath
---------------------
*Solaris only* Path to Solaris vaskeytab package.

- *Default*: 'UNSET'

solaris_adminpath
-----------------
*Solaris only* Path to Solaris package adminfile.

- *Default*: 'UNSET'

solaris_responsepattern
-----------------------
- *Default*: 'UNSET'
