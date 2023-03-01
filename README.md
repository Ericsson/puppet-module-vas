# puppet-module-vas

Puppet module to manage DELL Authentication Services previously known as VAS or Quest Authentication Services


## Compatibility

This module has been tested to work on the following systems with Puppet
version 7 with the Ruby version associated with those releases.
This module aims to support the current and previous major Puppet versions.

 * RedHat OS family 6
 * RedHat OS family 7
 * RedHat OS family 8
 * RedHat OS family 9
 * Suse OS family 11
 * Suse OS family 12
 * Suse OS family 15
 * Ubuntu 16.04
 * Ubuntu 18.04
 * Ubuntu 20.04

RedHat OS family members are: RedHat/CentOS/Scientific/OracleLinux
Suse OS family members are: SLED/SLES

When using the users.allow functionality in VAS, make sure to set the following option:

<pre>
---
pam::allowed_users:
  - 'ALL'
</pre>


## Hiera

Example hiera config:

<pre>
---
vas::username: 'joinuser'
vas::keytab_source: '/net/server/join.keytab'
vas::computers_ou: 'ou=computers,dc=example,dc=com'
vas::users_ou: 'ou=users,dc=example,dc=com'
vas::nismaps_ou: 'ou=nismaps,dc=example,dc=com'
vas::realm: 'realm.example.com'
</pre>


# Facts
The module creates facts as below:
vas_usersallow - A list of entries in /etc/opt/quest/vas/users.allow.
vas_domain - The domain that the host belongs to.
vas_server_type - The server types (GC, DC, PDC).
vas_servers - List of servers that VAS is using for authentication.
vas_site - The AD-site that the host belongs to.
vas_version - The complete version-string for the vas-client.
vasmajversion - The Major version of the vas-client.


# Parameters

Documentation for parameters have been moved to [REFERENCE.md](REFERENCE.md) file.
