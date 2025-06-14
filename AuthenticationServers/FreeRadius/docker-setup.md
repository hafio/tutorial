# Overview

Default `freeradius/freeradius-server` image doesn't have any clients or client profiles configured. Custom build is required to add these configurations and also expose ports.

Simply mount `clients.conf` or `authorize` files will not do as the radius server has a security check on startup to terminate if configuration files are globally writeable.

> Take note default ports are UDP `1812` & `1813`

# Required Files

- ## `docker-compose.yaml`

```yaml
name: project-RadiusServer

services:
  server:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: Free-Radius-Server
    image: hamlyn/freeradius-server:latest
    environment:
      - DEBUG=no
    ports:
      - 1812-1813:1812-1813/udp
    volumes:
      - "./raddb/clients.conf:/etc/raddb/clients.conf"
      - "./raddb/mods-config/files/authorize:/etc/raddb/mods-config/files/authorize"
      - "./start-again.sh:/usr/local/bin/start-again.sh"
```

- ## `Dockerfile`

```ini
FROM freeradius/freeradius-server:latest-alpine
COPY start-again.sh /usr/local/bin/start-again.sh
RUN chmod 755 /usr/local/bin/start-again.sh
COPY raddb /etc/raddb
EXPOSE 1812 1813
CMD ["/usr/local/bin/start-again.sh"]
```

- ## `start-again.sh`

```bash
#!/bin/sh

if [[ -n "${DEBUG}" ]]; then
	echo DEBUG=${DEBUG}
	d=`echo ${DEBUG} | awk '{ print tolower($0) }'`
	if [[ "${d:0:1}" == "y" ]] || [[ "${d}" == "true" ]]; then
		echo "Debug mode on"
		opts="-X"
	else
		opts="-f"
	fi
fi

# update permissions
chmod 755 /etc/raddb/clients.conf
chmod 755 /etc/raddb/mods-config/files/authorize

/opt/sbin/radiusd ${opts}
```
> `-f` argument is required for `radiusd` to run as a foreground process instead of as a daemon.
> <br>
> `radiusd` is located in `/opt/sbin` (might be different depending on the version of the image)

- ## `raddb/clients.conf`

Refer to [Free RadiusServer/clients.conf](https://www.freeradius.org/documentation/freeradius-server/4.0.0/raddb/clients.conf.html)

Quick sample below:

```conf
client radius-client {
	ipaddr = 127.0.0.1
	secret = radius-client-secret
	shortname = radius-client
}
```

Full `clients.conf` below:

```conf
# -*- text -*-
##
## clients.conf -- client configuration directives
##
##      $Id: 5f39ff120a44e3fb837d1893d54a7ebb31fd8749 $

#######################################################################
#
#  Define RADIUS clients (usually a NAS, Access Point, etc.).

#
#  There are a number of security practices which are critical in the
#  modern era.
#
#  * don't use RADIUS/UDP or RADIUS/TCP over the Internet.  Use RADIUS/TLS.
#
#  * If you do send RADIUS over UDP or TCP, don't send MS-CHAPv2.
#    Anyone who can see the MS-CHAPv2 data can crack it in milliseconds.
#
#  * use the "radsecret" program to generate secrets.  It uses Perl (sorry).
#    Every time you run it, it will generate a new strong secret.
#
#  * don't create shared secrets yourself.  Anything you create is likely to
#    be in a "cracking" dictionary, and will allow a hobbyist attacker
#    to crack the shared secret in a few minutes.
#
#  * Don't trust anyone who tells you to ignore the above recommendations.
#

#
#  Defines a RADIUS client.
#
#  '127.0.0.1' is another name for 'localhost'.  It is enabled by default,
#  to allow testing of the server after an initial installation.  If you
#  are not going to be permitting RADIUS queries from localhost, we suggest
#  that you delete, or comment out, this entry.
#
#

#
#  Each client has a "short name" that is used to distinguish it from
#  other clients.
#
#  In version 1.x, the string after the word "client" was the IP
#  address of the client.  In 2.0, the IP address is configured via
#  the "ipaddr" or "ipv6addr" fields.  For compatibility, the 1.x
#  format is still accepted.
#
client localhost {
        #  Only *one* of ipaddr, ipv4addr, ipv6addr may be specified for
        #  a client.
        #
        #  ipaddr will accept IPv4 or IPv6 addresses with optional CIDR
        #  notation '/<mask>' to specify ranges.
        #
        #  ipaddr will accept domain names e.g. example.org resolving
        #  them via DNS.
        #
        #  If both A and AAAA records are found, A records will be
        #  used in preference to AAAA.
        ipaddr = 127.0.0.1

        #  Same as ipaddr but allows v4 addresses only. Requires A
        #  record for domain names.
#       ipv4addr = *    # any.  127.0.0.1 == localhost

        #  Same as ipaddr but allows v6 addresses only. Requires AAAA
        #  record for domain names.
#       ipv6addr = ::   # any.  ::1 == localhost

        #
        #  A note on DNS:  We STRONGLY recommend using IP addresses
        #  rather than host names.  Using host names means that the
        #  server will do DNS lookups when it starts, making it
        #  dependent on DNS.  i.e. If anything goes wrong with DNS,
        #  the server won't start!
        #
        #  The server also looks up the IP address from DNS once, and
        #  only once, when it starts.  If the DNS record is later
        #  updated, the server WILL NOT see that update.
        #

        #
        #  The transport protocol.
        #
        #  If unspecified, defaults to "udp", which is the traditional
        #  RADIUS transport.  It may also be "tcp", in which case the
        #  server will accept connections from this client ONLY over TCP.
        #
        proto = *

        #
        #  The shared secret use to "encrypt" and "sign" packets between
        #  the NAS and FreeRADIUS.  You MUST change this secret from the
        #  default, otherwise it's not a secret any more!
        #
        #  The secret can be any string, up to 8k characters in length.
        #
        #  Control codes can be entered vi octal encoding,
        #       e.g. "\101\102" == "AB"
        #  Quotation marks can be entered by escaping them,
        #       e.g. "foo\"bar"
        #
        #  A note on security: The security of the RADIUS protocol
        #  depends COMPLETELY on this secret!  We recommend using a
        #  shared secret that at LEAST 16 characters long.  It should
        #  preferably be 32 characters in length.  The secret MUST be
        #  random, and should not be words, phrase, or anything else
        #  that is recognisable.
        #
        #  Computing power has increased enormously since RADIUS was
        #  first defined.  A hobbyist with a high-end GPU can try ALL
        #  of the 8-character shared secrets in about a day.  The
        #  security of shared secrets increases MUCH more with the
        #  length of the shared secret, than with number of different
        #  characters used in it.  So don't bother trying to use
        #  "special characters" or anything else in an attempt to get
        #  un-guessable secrets.  Instead, just get data from a secure
        #  random number generator, and use that.
        #
        #  You should create shared secrets using a method like this:
        #
        #       dd if=/dev/random bs=1 count=24 | base64
        #
        #  This process will give output which takes 24 random bytes,
        #  and converts them to 32 characters of ASCII.  The output
        #  should be accepted by all RADIUS clients.
        #
        #  You should NOT create shared secrets by hand.  They will
        #  not be random.  They will will be trivial to crack.
        #
        #  The default secret below is only for testing, and should
        #  not be used in any real environment.
        #
        secret = testing123

        #
        #  The global configuration "security.require_message_authenticator"
        #  flag sets the default for all clients.  That default can be
        #  over-ridden here, by setting it to a value.  If no value is set,
        #  then the default from the "radiusd.conf" file is used.
        #
        #  See that file for full documentation on the flag, along
        #  with allowed values and meanings.
        #
        #  This flag exists solely for legacy clients which do not send
        #  Message-Authenticator in all Access-Request packets.  We do not
        #  recommend setting it to "no".
        #
        #  The number one way to protect yourself from the BlastRADIUS
        #  attack is to update all RADIUS servers, and then set this
        #  flag to "yes".  If all RADIUS servers are updated, and if
        #  all of them have this flag set to "yes" for all clients,
        #  then your network is safe.  You can then upgrade the
        #  clients when it is convenient, instead of rushing the
        #  upgrades.
        #
        #  allowed values: yes, no, auto
        #
#       require_message_authenticator = no

        #
        #  The global configuration "security.limit_proxy_state"
        #  flag sets the default for all clients.  That default can be
        #  over-ridden here, by setting it to "no".
        #
        #  See that file for full documentation on the flag, along
        #  with allowed values,and meanings.
        #
        #  This flag exists solely for legacy clients which do not send
        #  Message-Authenticator in all Access-Request packets.  We do not
        #  recommend setting it to "no".
        #
        #  allowed values: yes, no, auto
        #
#       limit_proxy_state = yes

        #
        #  The short name is used as an alias for the fully qualified
        #  domain name, or the IP address.
        #
        #  It is accepted for compatibility with 1.x, but it is no
        #  longer necessary in >= 2.0
        #
#       shortname = localhost

        #
        # the following three fields are optional, but may be used by
        # checkrad.pl for simultaneous use checks
        #

#
        # The nas_type tells 'checkrad.pl' which NAS-specific method to
        #  use to query the NAS for simultaneous use.
        #
        #  Permitted NAS types are:
        #
        #       cisco
        #       computone
        #       livingston
        #       juniper
        #       max40xx
        #       multitech
        #       netserver
        #       pathras
        #       patton
        #       portslave
        #       tc
        #       usrhiper
        #       other           # for all other types

        #
        nas_type         = other        # localhost isn't usually a NAS...

        #
        #  The following two configurations are for future use.
        #  The 'naspasswd' file is currently used to store the NAS
        #  login name and password, which is used by checkrad.pl
        #  when querying the NAS for simultaneous use.
        #
#       login      = !root
#       password        = someadminpas

        #
        #  As of 2.0, clients can also be tied to a virtual server.
        #  This is done by setting the "virtual_server" configuration
        #  item, as in the example below.
        #
#       virtual_server = home1

        #
        #  A pointer to the "home_server_pool" OR a "home_server"
        #  section that contains the CoA configuration for this
        #  client.  For an example of a coa home server or pool,
        #  see raddb/sites-available/originate-coa
#       coa_server = coa

        #
        #  Response window for proxied packets.  If non-zero,
        #  then the lower of (home, client) response_window
        #  will be used.
        #
        #  i.e. it can be used to lower the response_window
        #  packets from one client to a home server.  It cannot
        #  be used to raise the response_window.
        #
#       response_window = 10.0

        #
        #  Connection limiting for clients using "proto = tcp".
        #
        #  This section is ignored for clients sending UDP traffic
        #
        limit {
                #
                #  Limit the number of simultaneous TCP connections from a client
                #
                #  The default is 16.
                #  Setting this to 0 means "no limit"
                max_connections = 16

                #  The per-socket "max_requests" option does not exist.

                #
                #  The lifetime, in seconds, of a TCP connection.  After
                #  this lifetime, the connection will be closed.
                #
                #  Setting this to 0 means "forever".
                lifetime = 0

                #
                #  The idle timeout, in seconds, of a TCP connection.
                #  If no packets have been received over the connection for
                #  this time, the connection will be closed.
                #
                #  Setting this to 0 means "no timeout".
                #
                #  We STRONGLY RECOMMEND that you set an idle timeout.
                #
                idle_timeout = 30
        }
}

# IPv6 Client
client localhost_ipv6 {
        ipv6addr        = ::1
        secret          = testing123
}

# All IPv6 Site-local clients
#client sitelocal_ipv6 {
#       ipv6addr        = fe80::/16
#       secret          = testing123
#}

#client example.org {
#       ipaddr          = radius.example.org
#       secret          = testing123
#}

#
#  You can now specify one secret for a network of clients.
#  When a client request comes in, the BEST match is chosen.
#  i.e. The entry from the smallest possible network.
#
#client private-network-1 {
#       ipaddr          = 192.0.2.0/24
#       secret          = testing123-1
#}

#client private-network-2 {
#       ipaddr          = 198.51.100.0/24
#       secret          = testing123-2
#}

#######################################################################
#
#  Per-socket client lists.  The configuration entries are exactly
#  the same as above, but they are nested inside of a section.
#
#  You can have as many per-socket client lists as you have "listen"
#  sections, or you can re-use a list among multiple "listen" sections.
#
#  Un-comment this section, and edit a "listen" section to add:
#  "clients = per_socket_clients".  That IP address/port combination
#  will then accept ONLY the clients listed in this section.
#
#  There are additional considerations when using clients from SQL.
#
#  A client can be link to a virtual server via modules such as SQL.
#  This link is done via the following process:
#
#  If there is no listener in a virtual server, SQL clients are added
#  to the global list for that virtual server.
#
#  If there is a listener, and the first listener does not have a
#  "clients=..." configuration item, SQL clients are added to the
#  global list.
#
#  If there is a listener, and the first one does have a "clients=..."
#  configuration item, SQL clients are added to that list.  The client
#  { ...} ` configured in that list are also added for that listener.
#
#  The only issue is if you have multiple listeners in a virtual
#  server, each with a different client list, then the SQL clients are
#  added only to the first listener.
#
#clients per_socket_clients {
#       client socket_client {
#               ipaddr = 192.0.2.4
#               secret = testing123
#       }
#}
```

- ##### `raddb/mods-config/files/authorize`

Quick sample below:

```conf
test-user Cleartext-Password := "test-password"
```

Full `authorize` sample:

```conf
#
# 	Configuration file for the rlm_files module.
# 	Please see rlm_files(5) manpage for more information.
#
# 	This file contains authentication security and configuration
#	information for each user.  Accounting requests are NOT processed
#	through this file.  Instead, see 'accounting', in this directory.
#
#	The first field is the user's name and can be up to
#	253 characters in length.  This is followed (on the same line) with
#	the list of authentication requirements for that user.  This can
#	include password, comm server name, comm server port number, protocol
#	type (perhaps set by the "hints" file), and huntgroup name (set by
#	the "huntgroups" file).
#
#	If you are not sure why a particular reply is being sent by the
#	server, then run the server in debugging mode (radiusd -X), and
#	you will see which entries in this file are matched.
#
#	When an authentication request is received from the comm server,
#	these values are tested. Only the first match is used unless the
#	"Fall-Through" variable is set to "Yes".
#
#	A special user named "DEFAULT" matches on all usernames.
#	You can have several DEFAULT entries. All entries are processed
#	in the order they appear in this file. The first entry that
#	matches the login-request will stop processing unless you use
#	the Fall-Through variable.
#
#	Indented (with the tab character) lines following the first
#	line indicate the configuration values to be passed back to
#	the comm server to allow the initiation of a user session.
#	This can include things like the PPP configuration values
#	or the host to log the user onto.
#
#	You can include another `users' file with `$INCLUDE users.other'

#
#	For a list of RADIUS attributes, and links to their definitions,
#	see: http://www.freeradius.org/rfc/attributes.html
#
#	Entries below this point are examples included in the server for
#	educational purposes. They may be deleted from the deployed
#	configuration without impacting the operation of the server.
#

#
# Deny access for a specific user.  Note that this entry MUST
# be before any other 'Auth-Type' attribute which results in the user
# being authenticated.
#
# Note that there is NO 'Fall-Through' attribute, so the user will not
# be given any additional resources.
#
#lameuser	Auth-Type := Reject
#		Reply-Message = "Your account has been disabled."

#
# Deny access for a group of users.
#
# Note that there is NO 'Fall-Through' attribute, so the user will not
# be given any additional resources.
#
#DEFAULT	Group == "disabled", Auth-Type := Reject
#		Reply-Message = "Your account has been disabled."
#

#
# This is a complete entry for "steve". Note that there is no Fall-Through
# entry so that no DEFAULT entry will be used, and the user will NOT
# get any attributes in addition to the ones listed here.
#
#steve	Cleartext-Password := "testing"
#	Service-Type = Framed-User,
#	Framed-Protocol = PPP,
#	Framed-IP-Address = 172.16.3.33,
#	Framed-IP-Netmask = 255.255.255.0,
#	Framed-Routing = Broadcast-Listen,
#	Framed-Filter-Id = "std.ppp",
#	Framed-MTU = 1500,
#	Framed-Compression = Van-Jacobsen-TCP-IP

#
# The canonical testing user which is in most of the
# examples.
#
#bob	Cleartext-Password := "hello"
#	Reply-Message := "Hello, %{User-Name}"
#

#
# This is an entry for a user with a space in their name.
# Note the double quotes surrounding the name.  If you have
# users with spaces in their names, you must also change
# the "filter_username" policy to allow spaces.
#
# See raddb/policy.d/filter, filter_username {} section.
#
#"John Doe"	Cleartext-Password := "hello"
#		Reply-Message = "Hello, %{User-Name}"

#
# Dial user back and telnet to the default host for that port
#
#Deg	Cleartext-Password := "ge55ged"
#	Service-Type = Callback-Login-User,
#	Login-IP-Host = 0.0.0.0,
#	Callback-Number = "9,5551212",
#	Login-Service = Telnet,
#	Login-TCP-Port = Telnet

#
# Another complete entry. After the user "dialbk" has logged in, the
# connection will be broken and the user will be dialed back after which
# he will get a connection to the host "timeshare1".
#
#dialbk	Cleartext-Password := "callme"
#	Service-Type = Callback-Login-User,
#	Login-IP-Host = timeshare1,
#	Login-Service = PortMaster,
#	Callback-Number = "9,1-800-555-1212"

#
# user "swilson" will only get a static IP number if he logs in with
# a framed protocol on a terminal server in Alphen (see the huntgroups file).
#
# Note that by setting "Fall-Through", other attributes will be added from
# the following DEFAULT entries
#
#swilson	Service-Type == Framed-User, Huntgroup-Name == "alphen"
#		Framed-IP-Address = 192.0.2.65,
#		Fall-Through = Yes

#
# If the user logs in as 'username.shell', then authenticate them
# using the default method, give them shell access, and stop processing
# the rest of the file.
#
#DEFAULT	Suffix == ".shell"
#		Service-Type = Login-User,
#		Login-Service = Telnet,
#		Login-IP-Host = your.shell.machine


#
# The rest of this file contains the several DEFAULT entries.
# DEFAULT entries match with all login names.
# Note that DEFAULT entries can also Fall-Through (see first entry).
# A name-value pair from a DEFAULT entry will _NEVER_ override
# an already existing name-value pair.
#

# Sample defaults for all framed connections.
#
#DEFAULT	Service-Type == Framed-User
#	Framed-IP-Address = 255.255.255.254,
#	Framed-MTU = 576,
#	Service-Type = Framed-User,
#	Fall-Through = Yes

#
# Default for PPP: dynamic IP address, PPP mode, VJ-compression.
# NOTE: we do not use Hint = "PPP", since PPP might also be auto-detected
#	by the terminal server in which case there may not be a "P" suffix.
#	The terminal server sends "Framed-Protocol = PPP" for auto PPP.
#
DEFAULT	Framed-Protocol == PPP
	Framed-Protocol = PPP,
	Framed-Compression = Van-Jacobson-TCP-IP

#
# Default for CSLIP: dynamic IP address, SLIP mode, VJ-compression.
#
DEFAULT	Hint == "CSLIP"
	Framed-Protocol = SLIP,
	Framed-Compression = Van-Jacobson-TCP-IP

#
# Default for SLIP: dynamic IP address, SLIP mode.
#
DEFAULT	Hint == "SLIP"
	Framed-Protocol = SLIP

#
# Last default: rlogin to our main server.
#
#DEFAULT
#	Service-Type = Login-User,
#	Login-Service = Rlogin,
#	Login-IP-Host = shellbox.ispdomain.com

# #
# # Last default: shell on the local terminal server.
# #
# DEFAULT
# 	Service-Type = Administrative-User


# On no match, the user is denied access.


#########################################################
# You should add test accounts to the TOP of this file! #
# See the example user "bob" above.                     #
#########################################################
```

# Build

Execute `docker-compose build --no-cache --pull` in the directory of `docker-compose.yaml`, `Dockerfile`, `start-again.sh`, and `raddb` directory.

Alternatively execute `docker build -t hamlyn/freeradius-server:latest --no-cache --pull`

# Run

Quick start example `docker-compose up -d`.

There are not environmental variables required.