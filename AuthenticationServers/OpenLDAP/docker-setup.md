# Overview

Quick start example to spin up Open LDAP server (`osixia/openldap:latest`) and Simple PHP LDAP Administration GUI (`osixia/phpldapadmin:latest`)

> Take note the stock image does not have any organization profile setup so `ldapadd` needs to be executed a few times to for basic organizational units, users, and groups to be created.

# `docker-compose.yaml`
```ini
name: project-OpenLDAP

services:
  ldap-server:
    container_name: OpenLDAP-server
    image: osixia/openldap:latest
    environment:
      - LDAP_ORGANISATION=test-org
      - LDAP_DOMAIN=test-domain.loc
      - "LDAP_BASE_DN=dc=test-domain,dc=loc"
      - LDAP_ADMIN_PASSWORD=admpassword
    volumes:
      - "./ldap_add_ou.sh:/usr/local/bin/ldap_add_ou.sh"
      - "./ldap_add_user.sh:/usr/local/bin/ldap_add_user.sh"
      - "./ldap_add_group.sh:/usr/local/bin/ldap_add_group.sh"
      - "./ldap_search.sh:/usr/local/bin/ldap_search.sh"
    ports:
      - 389:389
      - 636:636

  ldap-admin:
    container_name: PHP-LDAP
    image: osixia/phpldapadmin:latest
    environment:
      - PHPLDAPADMIN_LDAP_HOSTS=ldap-server
    ports:
      - 14443:443
    depends_on:
      - ldap-server
```
> Take note that `14443` (can be changed) is mapped to the PHP LDAP Administration GUI port `443` so access via [https://localhost:14443](https://localhost:14443)

# Additional files
> These files are actually optional but helps in setting up the LDAP profiles initially.

- ## `ldap_add_ou.sh`
```bash
#!/bin/bash

ldapadd -x -w ${LDAP_ADMIN_PASSWORD} -D "cn=admin,${LDAP_BASE_DN}" << EOF
# LDIF file to add organizational unit "ou=testorg1" under ${LDAP_BASE_DN}
dn: ou=testorg1,${LDAP_BASE_DN}
objectClass: organizationalUnit
ou: testorg1

# LDIF file to add organizational unit "ou=testorg2" under ${LDAP_BASE_DN}
dn: ou=testorg2,${LDAP_BASE_DN}
objectClass: organizationalUnit
ou: testorg2
EOF
```

- ## `ldap_add_user.sh`
```bash
#!/bin/bash

ldapadd -x -w ${LDAP_ADMIN_PASSWORD} -D "cn=admin,${LDAP_BASE_DN}" << EOF
# LDIF file to Create user "testusera" in "ou=testorg1" under ${LDAP_BASE_DN}
dn: cn=testusera,ou=testorg1,${LDAP_BASE_DN}
objectClass: inetOrgPerson
cn: testusera
sn: TestUserA
uid: testusera
userPassword: password

# LDIF file to Create user "testuserb" in "ou=testorg2" under ${LDAP_BASE_DN}
dn: cn=testuserb,ou=testorg2,${LDAP_BASE_DN}
objectClass: inetOrgPerson
cn: testuserb
sn: TestUserB
uid: testuserb
userPassword: password

# LDIF file to Create user "testuserc" in "ou=testorg2" under ${LDAP_BASE_DN}
dn: cn=testuserc,ou=testorg2,${LDAP_BASE_DN}
objectClass: inetOrgPerson
cn: testuserc
sn: TestUserC
uid: testuserc
userPassword: password
EOF
```

- ## `ldap_add_group.sh`
```bash
#!/bin/bash

ldapadd -x -w ${LDAP_ADMIN_PASSWORD} -D "cn=admin,${LDAP_BASE_DN}" << EOF
# Group: grp1-team
dn: cn=grp1-team,${LDAP_BASE_DN}
objectClass: top
objectClass: groupOfNames
cn: grp1-team
description: Test Group 1 Team
member: cn=testusera,ou=testorg1,${LDAP_BASE_DN}
member: cn=testuserb,ou=testorg2,${LDAP_BASE_DN}

# Group: grp2-team
dn: cn=grp2-team,${LDAP_BASE_DN}
objectClass: top
objectClass: groupOfNames
cn: grp2-team
description: Test Group 2 Team
member: cn=testusera,ou=testorg1,${LDAP_BASE_DN}
member: cn=testuserc,ou=testorg2,${LDAP_BASE_DN}
EOF
```

- ## `ldap_search.sh`
```bash
#!/bin/bash

ldapsearch -x -b ${LDAP_BASE_DN} -D "cn=admin,${LDAP_BASE_DN}" -w ${LDAP_ADMIN_PASSWORD} -s sub "objectclass=*"
```

# Run

Ensure all above files are in the same directory, then execute `docker-compose up -d` in the same directory.