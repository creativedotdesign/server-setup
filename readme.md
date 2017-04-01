Automated server setup using Vesta and Ansible Local:
 - Debian 8
 - VestaCP install
 - PHP 7.0 FPM
 - MariaDB
 - MemCacheD
 - NginX with GeoIP, ngx_cache_purge

To build the test VM:
- Install Vagrant
- Ensure provisioner for your hypervisor is available, eg VirtualBox.
- cd to repo dir
- Run `vagrant up`

To-do:
 - Secure/private options files with Git exclusions
 - Finish replacing PHP5 with PHP7 (incl. Vesta changes)
 - Any further requirements when full spec. has been defined