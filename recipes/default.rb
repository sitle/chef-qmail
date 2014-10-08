#
# Cookbook Name:: chef-qmail
# Recipe:: default
#
# Copyright (C) 2014 DSI
#
# All rights reserved - Do Not Redistribute
#
src_package = '/usr/local/src'
qmail_home = '/var/qmail'
qmail_log = '/var/log/qmail'
qmail_service = '/service'
qmail_bals = '/data/mail'
ldapuid = '1007'
ldapgid = '104'

##################################
# Paquets necessaires
##################################

package 'gcc' do
  action :install
end

# package tar
package 'tar' do
  action :install
end

# package csh
package 'csh' do
  action :install
end

# package ucspi-tcp
package 'ucspi-tcp' do
  action :install
end

# package daemontools
package 'daemontools' do
  action :install
end

# package daemontools-run
package 'daemontools-run' do
  action :install
end

# package libldap2-dev
package 'libldap2-dev' do
  action :install
end

# package libssl-dev
package 'libssl-dev' do
  action :install
end

# package git-core
package 'git-core' do
  action :install
end

###############################
# Courier-imap dependencies
###############################
# package libtool
package 'libtool' do
  action :install
end

# package expect
package 'expect' do
  action :install
end

# package libgdbm-dev
package 'libgdbm-dev' do
  action :install
end

# package g++
package 'g++' do
  action :install
end

##################################
# Creation des users and groups
##################################

group 'nofiles' do
  action :create
end

group 'vgroup' do
  gid "#{ldapgid}"
  action :create
  non_unique true
end

group 'qmail' do
  action :create
end

user 'vuser' do
  gid 'vgroup'
  uid "#{ldapuid}"
  home '/home/vuser'
  action :create
end

user 'alias' do
  gid 'nofiles'
  home '/var/qmail/alias'
  action :create
end

user 'qmaild' do
  gid 'nofiles'
  home '/var/qmail'
  action :create
end

user 'qmaill' do
  gid 'nofiles'
  home '/var/qmail'
  action :create
end

user 'qmailp' do
  gid 'nofiles'
  home '/var/qmail'
  action :create
end

user 'qmailq' do
  gid 'qmail'
  home '/var/qmail'
  action :create
end

user 'qmailr' do
  gid 'qmail'
  home '/var/qmail'
  action :create
end

user 'qmails' do
  gid 'qmail'
  home '/var/qmail'
  action :create
end

##################################
# Creation des repertoires de base
##################################

# directory '#{daemontools_path}' do
# owner 'root'
#	group 'root'
#	mode '0755'
#	action :create
# end

directory "#{src_package}" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory "#{qmail_log}" do
  owner 'qmaill'
  group 'root'
  mode '0755'
  action :create
end

directory "#{qmail_log}/smtpd" do
  owner 'qmaill'
  group 'root'
  mode '0755'
  action :create
end

directory "#{qmail_home}" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory '/data' do
  owner 'root'
  group 'vgroup'
  mode '0775'
  action :create
end

directory "#{qmail_bals}" do
  owner 'vuser'
  group 'vgroup'
  mode '0700'
  action :create
end

##################################
# Compilation de qmail + qmail-ldap
##################################

bash 'download-compilation-qmail-src-ldap' do
  user 'root'
  cwd "#{src_package}"
  code <<-EOH
  git clone  https://github.com/stephaneLII/qmail-src-ldap.git
  cd qmail-src-ldap
  make setup check
  ./config-fast test.gov.pf
  EOH
end

##################################
# Download et compilation de courier-authlib
##################################
bash 'download-courier-authlib' do
  user 'root'
  cwd "#{src_package}"
  code <<-EOH
  wget http://softlayer-dal.dl.sourceforge.net/project/courier/authlib/0.66.1/courier-authlib-0.66.1.tar.bz2
  bunzip2 courier-authlib-0.66.1.tar.bz2
  tar xvf courier-authlib-0.66.1.tar
  cd courier-authlib-0.66.1
  EOH
end

##################################
# Download et compilation de courier-imap
##################################
bash 'download-courier-imap' do
  user 'root'
  cwd "#{src_package}"
  code <<-EOH
  wget http://tcpdiag.dl.sourceforge.net/project/courier/imap/4.15.1/courier-imap-4.15.1.tar.bz2
  bunzip2 courier-imap-4.15.1.tar.bz2
  tar xvf courier-imap-4.15.1.tar
  cd courier-imap-4.15.1
  EOH
end

##################################
# Creation de scripts controles
##################################
cookbook_file 'qmailctl' do
  path "#{qmail_home}/bin/qmailctl"
  action :create
  mode '0755'
end

link '/usr/bin/qmailctl' do
  to '#{qmail_home}/bin/qmailctl'
end

###############################################
# Parametrage de qmail
###############################################

cookbook_file 'defaultdelivery' do
  path "#{qmail_home}/control/defaultdelivery"
  action :create
  mode '0644'
end

cookbook_file 'concurrencyincoming' do
  path '#{qmail_home}/control/concurrencyincoming'
  action :create
  mode '0644'
end

cookbook_file 'qmail-smtpd.rules' do
  path "#{qmail_home}/control/qmail-smtpd.rules"
  action :create
  mode '0644'
end

cookbook_file 'qmail-pop3d.rules' do
  path "#{qmail_home}/control/qmail-pop3d.rules"
  action :create
  mode '0644'
end

cookbook_file 'qmail-imapd.rules' do
  path "#{qmail_home}/control/qmail-imapd.rules"
  action :create
  mode '0644'
end

cookbook_file 'rcpthosts' do
  path "#{qmail_home}/control/rcpthosts"
  action :create
  mode '0644'
end

cookbook_file 'locals' do
  path "#{qmail_home}/control/locals"
  action :create
  mode '0644'
end

###############################################
# Parametrage acces LDAP
###############################################
cookbook_file 'ldapbasedn' do
  path "#{qmail_home}/control/ldapbasedn"
  action :create
  mode '0644'
end

cookbook_file 'ldappassword' do
  path "#{qmail_home}/control/ldappassword"
  action :create
  mode '0644'
end

cookbook_file 'ldapgrouppassword' do
  path "#{qmail_home}/control/ldapgrouppassword"
  action :create
  mode '0644'
end

cookbook_file 'ldapgid' do
  path "#{qmail_home}/control/ldapgid"
  action :create
  mode '0644'
end

cookbook_file 'ldapuid' do
  path "#{qmail_home}/control/ldapuid"
  action :create
  mode '0644'
end

cookbook_file 'ldapgrouplogin' do
  path "#{qmail_home}/control/ldapgrouplogin"
  action :create
  mode '0644'
end

cookbook_file 'ldaplocaldelivery' do
  path "#{qmail_home}/control/ldaplocaldelivery"
  action :create
  mode '0644'
end

cookbook_file 'ldaplogin' do
  path "#{qmail_home}/control/ldaplogin"
  action :create
  mode '0644'
end

cookbook_file 'ldapobjectclass' do
  path "#{qmail_home}/control/ldapobjectclass"
  action :create
  mode '0644'
end

cookbook_file 'ldaprebind' do
  path "#{qmail_home}/control/ldaprebind"
  action :create
  mode '0644'
end

cookbook_file 'ldapserver' do
  path "#{qmail_home}/control/ldapserver"
  action :create
  mode '0644'
end

cookbook_file 'dirmaker' do
  path "#{qmail_home}/control/dirmaker"
  action :create
  mode '0644'
end

cookbook_file 'create_homedir' do
  path "#{qmail_home}/bin/create_homedir"
  action :create
  mode '0775'
  group 'qmail'
end

bash 'MakeRules' do
  user 'root'
  cwd "#{qmail_home}/control"
  code <<-EOH
  make
  EOH
end

cookbook_file 'qmail-imap-run' do
  path "#{qmail_home}/boot/qmail-imapd/run"
  action :create
  mode '0755'
  group 'qmail'
end

cookbook_file 'imapd' do
  path "#{qmail_home}/bin/imapd"
  action :create
  mode '0755'
  group 'qmail'
end

cookbook_file 'imaplogin' do
  path "#{qmail_home}/bin/imaplogin"
  action :create
  mode '0755'
  group 'qmail'
end

###############################################
# Mise en place des liens symboliques
###############################################

link "#{qmail_service}" do
  to '/etc/service'
end

link "#{qmail_service}/qmail" do
  to "#{qmail_home}/boot/qmail"
end

link "#{qmail_service}/qmail-smtpd" do
  to '#{qmail_home}/boot/qmail-smtpd'
end

link "#{qmail_service}/qmail-imapd" do
  to "#{qmail_home}/boot/qmail-imapd"
end

link "#{qmail_service}/qmail-pop3d" do
  to "#{qmail_home}/boot/qmail-pop3d"
end

link '/usr/local/bin/setuidgid' do
  to '/usr/bin/setuidgid'
end

link '/usr/local/bin/multilog' do
  to '/usr/bin/multilog'
end

link '/usr/local/bin/tcprules' do
  to '/usr/bin/tcprules'
end

link '/usr/local/bin/tcpserver' do
  to '/usr/bin/tcpserver'
end

link '/usr/local/bin/softlimit' do
  to '/usr/bin/softlimit'
end

link '/usr/local/bin/supervise' do
  to '/usr/bin/supervise'
end

link '/usr/local/bin/svok' do
  to '/usr/bin/svok'
end

link '/usr/local/bin/svscan' do
  to '/usr/bin/svscan'
end

link '/usr/local/bin/tai64nlocal' do
  to '/usr/bin/tai64nlocal'
end

bash 'Qmail-restArt' do
  user 'root'
  cwd "#{qmail_home}/bin"
  code <<-EOH
  initctl  stop svscan ; initctl   start svscan
  EOH
end
