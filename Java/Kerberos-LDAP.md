# Overview

This is a generic guide used to configure Java-based applications to utilize Kerberos Authentication for LDAP Authentication. The guide is specific to for Java applications hosted in Linux servers that have Kerberos authentication enabled.

## Steps

1. Ensure Linux host is already configured with Kerberos Authentication for LDAP
2. Create Kerberos Keytab File
3. Create Java Authentication and Authorization Service (JAAS) Configuration File
4. Update JDBC Connection String and Connection Username
5. Add/Update Java Virtual Machine Module Runtime Parameters

### 1. Ensure Linux host is already configured with Kerberos Authentication for LDAP

The Linux host has to be configured with Kerberos Authentication for LDAP e.g. joined the realm. If not already done so, please follow Kerberos instructions. 

If the host is configured, there should be a Kerberos Configuration File /etc/krb5.conf available:
```ini
[libdefaults]
	dns_lookup_realm = false
    dns_lookup_kdc = true
	ticket_lifetime = 24h
	renew_lifetime = 7d
	forwardable = true
	rdns = false
	pkinit_anchors = FILE:<DOMAIN CA-BUNDLE CERTIFICATE>
	default_realm = <DOMAIN>
	default_ccache_name = KEYRING:persistent:%{uid}
	udp_preference_limit = 0

[realms]
<DOMAIN> = {
}

[domain_realm]
.<LDOMAIN> = <DOMAIN>
<LDOMAIN> = <DOMAIN>
```
> `<DOMAIN>` → Realm Domain (e.g. LDAP-DOMAIN.COM) in **uppercase** <br>
> `<LDOMAIN>` → Realm Domain (e.g. ldap-domain.com) in **lowercase**

### 2. Create Kerberos Keytab File

Enter into kutil cli mode by typing `kutil`. Execute the following lines:
```bash
add_entry -password -p <service account> -k 1 -e aes256-crt-hmas-sha1-96
write_kt <filename>
quit
```
> `<service account>` → Full LDAP Username e.g. user@ldap-domain.com <br>
> `<filename>` → Desired Keytab filename

Enter LDAP account password when prompted. Take note of the full path location of the file as this will need to be referenced in Step 5.

### 3. Create Java Authentication and Authorization Service (JAAS) Configuration File

Create the following file:
```ini
SQLJDBC {
	com.sun.security.auth.module.Krb5LoginModule required
	useKeyTab=true
	keyTab=”<filepath>”
	storeKey=true
	doNotPrompt=true
	principal=”<service account>";
};
```
> `<filepath>` → Full path of the Kerberos Keytab file (created in previous step) <br>
> `<principal>` → Full LDAP Username e.g. user@ldap-domain.com

Take note of the full path location of the file as this will need to be referenced in Step 5.

### 4. Update JDBC Connection String and Connection Username

Update JDBC Connection String in your application:
```
jdbc:sqlserver://<SQL Server FDQN>:<SQL Server Port>;databaseName=<DB NAME>;encrypt=false;integratedSecurity=true;authenticationScheme=JavaKerberos
```

Also update the username in the same page to reflect the LDAP username e.g. user@ldap-domain.com

### 5. Add/Update Java Virtual Machine Module Runtime Parameters

Make the the JVM has the following runtime parameters:
```ini
java.security.krb5.conf=<KRB5 FILE>
java.security.auth.login.config=<JAAS FILE>
```
> `<KRB5 FILE>` → Full path of Kerberos configuration file e.g /etc/krb5.conf or the file created in Step 1 <br>
> `<JAAS FILE>` → Full path of JAAS file created in Step 3

Or if starting Java app from the command line, use:
- `-Djava.security.krb5.conf=<KRB5 FILE>`
- `-Djava.security.auth.login.config=<JAAS FILE>`
