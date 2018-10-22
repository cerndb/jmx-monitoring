# JRE remote monitoring configuration

##### Table of Contents  

1. [General description](#general_description)
1. [File and folder structure](#project__FileAndFolder_sturcture)
1. [JMX authentication](#jmx_authentication)
1. [JMX with SSL](#jmx_with_ssl)
1. [Troubleshooting and Debugging JMX LDAP authentication](#jmx_auth_troubleshooting_and_debugging)

<a name="general_description"/>

## General description

The JAVA applications are running on JAVA Virtual Machine (JVM). The JVM has been designed that via a JAVA Management Extensions (JMX) agent it can be monitored. This means that with a client application such as JConsole or JAVA Mission Control (JMC) a developer can connect to the local/remote enironment's JVM and extract useful information about the developed application. In nutshells its like an application insights for JAVA applications to see whats going on under the hood as your code is running. To enable the remote monitoring features you have to specify additional JAVA command line arguments. In this repository you will find the neccessary command line arguments which are needed for connecting your monitoring console to the JMX agent. 

For better overview and simplicity reasons I'm going to use the Tomcat way as an example how you can extend the command line arguments list. When you start the Tomcat application server in tomcat home bin directory you can create setenv.sh file where you can apply extra command line arguments. If this file exists there it will automatically executed during the startup. You will see in repositories setenv.sh the following lines: **"export CATALINA_OPTS="$CATALINA_OPTS -D$YourArgumentName=$value"**. As you start the tomcat you specify the starting command line arguments in the **"CATALINA_OPTS"** environment variable and with those lines you just extend the environment variables list. In case you prefer to do it with one line as you start your application you just simply list the arguments space separated after each other. In the example line you the **"$YourArgumentName"** stands for your the JAVA argument name and **"$value"** stands for the actual value of the argument.

For some command line arguments the JAVA framework allows you to create group them into a properties file. The values setted from the properties files are going to be hidden as you grep the running proccess. This is handy if you have to include the passwords for SSL and for the trusted store. 

<a name="project__FileAndFolder_sturcture"/>

## File and folder structure

The folder structure is designed to separate the configuration settings as much as the JAVA framework allows. In the root directory you find the **"setenv.sh"** file. This is Linux executable file usually used in "Tomcat"/"TomEE" application server context and it lives under the "$CATALINA_HOME/bin/" folder. $CATALINA_HOME is the home folder of the application server (If file does not exists then you craete it, you grant the executable right.The application server by default checks during the start if the file exists, if exists then executes it). The executable main task is adds the extra JAVA command line arguments as the application server starts. So JVM will start with the monitoring enabled settings. If you have a different application server then you need to find the relavant configuration where you can add the command line arguments. Or alternatively you can list the command line arguments when you start the application server. 

**Please note that there are couple of configuration settings which can't live together for example: JMX basic authentication with JMX LDAP authentication. The excluding settings are commented out. Its advised to just walk through first on the settings and on their descriptions. Based on that you can enable the settings which you need.**

The JAVA runtime framework allows for some command line arguments to be separated into smaller configuration files. This approach hides those arguments defined in the configuration file. This means their value will be set, but not visible when you list the running applications ("ps aux |grep java" ,Windows task manager).

All the folders which you find in the repositories root directory are folders which are containing the custom configuration hidden arguments. In the current examples I assume that those folder are living under the "/opt" folder. In case you create the folders in a different path or rename the file names please don't forget to follow up the changes when you link the settings as JAVA command line arguments.

The **"cert"** contains the certificate related settings. Host certificate for SSL of the host and trusted certificate key store for trusted servers which require SSL. Within the folder you find the **"ssl.properties"** configuration file which contains the actual argument names and values for linking the certificates. More description you find in the configuration file.

In the the **"java_opts"** folder you will find a configuration file called **"management.properties"**. This file contains a set of command line arguments which are living under the **"com.sun.management.jmxremote"** namespace. More information about the setting possibilities you can find in the configuration file.

The **"jmx_access"** folder contains the JMX authentication specific configuration. 
* In the example **"jmxremote.access"** file contains the roles which the user can have once it has made a successful login with the JMX.
* In the **"jmxremote.password"** file you will find in "$username $password" format the basic JMX  authentication example 
* In the **single_role_check.config** file you will find an LDAP's Login module example with one condition check
* In the **multi_role_check.config** file you will find an LDAP's Login module example with multiple condition check (real life use case: based on LDAP group membership specify the JMX monitoring role. )

<a name="jmx_authentication"/>

## JMX authentication

For JMX connection you need to specify first what kind of authentication method you want to use. 
* **Anonymous** for this type of authentication you need to set "com.sun.management.jmxremote.authenticate" to *"false"* in the "management.properties" file and skip the extra configuration in the jmx_access folder.
* **Basic** for this type of authentication you need to set "com.sun.management.jmxremote.authenticate" to *"true"* and comment out the "access.file" and "password.file" lines in the "management.properties" file. Update the enabled file's content for the values which you want to use for username and password plus match the roles with the usernames.
* **LDAP** for this type of authentication you need to enable LDAP login module configuration file in the "setenv.sh" ("java.security.auth.login.config" attribute), set "com.sun.management.jmxremote.authenticate" to *"true"* and comment out the "access.file" and "login.config" (since you can have multiple login modules listed in the LDAP login config file with this attribute you have to specify which block of login settings you want to be active). 

<a name="jmx_with_ssl"/>

## JMX with SSL 

For authentications its highly advised to use SSL communication, but for evauluation you most probably want to skip it. 

Related to SSL we are talking about 2 things. One is the host certificate and the other one is the LDAP server's hostcertificate. Most probably you will need both because you don't want to send your username and password unsecured.

For both cases you will find sample settings in the "/cert/ssl.properties" file. 

**Trusted key sotre**
If you want to secure the communication between the JMX running remote server and the LDAP server then you need to create a trusted key store file which contains the certificate of the target LDAP server and you need to link that key store to the JVM as a command line argument.

The key store file you can create with the following command:

```
#> keytool -importcert -keystore /$TargetPath/trustedRemoteCertStore -alias $YourAlias -file $YourCertFileName.crt -deststoretype PKCS12 
```
* $TargetPath is the path where you want to have the trusted key store file created
* $YourAlias is the alias name how you want your certificate listed in the key store file
* $YourCertFileName is the name of your cert file which you want to import into the key store file
* Please note that with -deststoretype we specify that the format of the key store file is going to be in PKCS12 format (not JKS, FYI from JAVA 9 Oracle will change its default JKS type to PKCS12. You can use JKS if you want, this settings is just an advice ). Another really important thing is that if you have host certificate also (which is usually the case) then you have to keep the type of the host certificate the same as you specified for the trusted key store. My experience is that Tomcat complains and not starts if you have different type setting.

In case you don't have a keystore file it will create one for you. In case you have one then most probably it will ask you for a pass phrase.

The LDAP login module's authentication is happening on a lower level. **You need one additional step**. You need to add your LDAP server certificate to the default JRE trusted certificate key store. For some weired reason having custom SSL trusted store was not enough for LDAP authentication. This means you have to add your certificate to the **"$JAVA_HOME/jre/lib/security/cacerts"** with the same import cert command described earlier. The default password for the JAVA default key store file is "changeit"

**Host certificate**

For linking the host certificate you need just get your certificate on the remote server and set the arguments. 

<a name="jmx_auth_troubleshooting_and_debugging"/>

## Troubleshooting and Debugging JMX LDAP authentication

If you enable JMX LDAP authentication debugging the following logs will appear in your log file (in case of Tomcat/TomEE it will be in the $CATALINA_HOME/logs/catalina.out )

This is a successful message if everything works correctly and you use LDAP authentication with SSL. If you disabled the SSL you will get "SSL disabled" instead of "SSL enabled".

```
[LdapLoginModule] authentication-first mode; SSL enabled
[LdapLoginModule] user provider: *$YourLDAPSERVERURL
[LdapLoginModule] tryFirstPass failed: javax.security.auth.login.FailedLoginException: No password was supplied
[LdapLoginModule] attempting to authenticate user: *$username
[LdapLoginModule] searching for entry belonging to user: *$username
[LdapLoginModule] found entry: *$userLDAPDNName
[LdapLoginModule] authentication succeeded
[LdapLoginModule] added LdapPrincipal *$userLDAPDNName to Subject
[LdapLoginModule] added UserPrincipal *$username to Subject
[LdapLoginModule] added UserPrincipal *$targetRole to Subject 
```

Parameters in the log:
* ***$YourLDAPSERVERURL**  this field will contain your LDAP server name
* ***$username** this field will contain the user name which you will try to authenticate.
* ***$userLDAPDNName** the DN name in the LDAP server for the queried user
* ***$targetRole** target mapped role name


**As you will see the error message's text is the same for the different errors. So I highly advice you to go with the following steps:**
* verify your LDAP query is returning something(in Linux you can use the ldapsearch command for that) 

Replace the "$ParamterName" variables with your own variable values.

```
// Anonymous query
#> ldapsearch -x -h $YourLDAPServerName -b "$EntryPointOfTheLDAPTree" "$YourLDAPQuery"

// Authentication required query (-W will ask for the password for the user in who's name the query is running)
#> ldapsearch -W -x -h $YourLDAPServerName -D "$UserThatRunsTheQuery" -b "$EntryPointOfTheLDAPTree" "$YourLDAPQuery"
```

* try to connect first without SSL
* once you have the previous steps correct add the SSL layer

### Wrong user name or password

In the following example you see the general error message from the log.

```
[LdapLoginModule] authentication-first mode; SSL disabled
[LdapLoginModule] user provider: *$YourLDAPSERVERURL
[LdapLoginModule] tryFirstPass failed: javax.security.auth.login.FailedLoginException: No password was supplied [LdapLoginModule] attempting to authenticate user: *$username
[LdapLoginModule] authentication failed 
[LdapLoginModule] aborted authentication 
```
Parameters in the error:
* ***$YourLDAPSERVERURL**  this field will contain your LDAP server name
* ***$username** this field will contain the user name which you will try to authenticate.

Why you get this error (basically you receive a standard error message for every issue):
* You have a wrong user name
* You have a wrong password

You get the "No password was supplied" error because the LDAP login module tries to read the username and password first from the shared content object. If you do not have anything specified there you will get this message. Its a warning, in case you want to use for authentication the username and password entered in the monitoring client application then you can pass by that warning.


### Anonymous query succeeded, but authentication failed

This is the log if you have anonymous query enabled for the server

```
[LdapLoginModule] search-first mode; SSL disabled
[LdapLoginModule] user provider: *$YourLDAPSERVERURL
[LdapLoginModule] searching for entry belonging to user: *$username
[LdapLoginModule] found entry: *$userLDAPDNName
[LdapLoginModule] attempting to authenticate user: *$username
[LdapLoginModule] authentication failed
[LdapLoginModule] aborted authentication 
```

Here the general error hides that on the target LDAP server the authentication is disabled. From the log you can see that the query run for getting the DN name for the user was successful but the authentication failed.

Parameters in the error:
* ***$YourLDAPSERVERURL**  this field will contain your LDAP server name
* ***$username** this field will contain the user name which you will try to authenticate.
* ***$userLDAPDNName** the DN name in the LDAP server for the queried user

### SSL LDAP certificate error

```
[LdapLoginModule] authentication-first mode; SSL enabled
[LdapLoginModule] user provider: *$YourLDAPSERVERURL
[LdapLoginModule] tryFirstPass failed: javax.security.auth.login.FailedLoginException: No password was supplied [LdapLoginModule] attempting to authenticate user: *$username
[LdapLoginModule] authentication failed 
[LdapLoginModule] aborted authentication 
```

Parameters in the error:
* ***$YourLDAPSERVERURL**  this field will contain your LDAP server name
* ***$username** this field will contain the user name which you will try to authenticate.

Reasons:
* LDAP SSL not provided in trusted store
* LDAP SSL was not added to the JRE default trusted key store file

### LDAP query returned without a row

Here you see that the first query failed for whatever reason, but the second succeeded.

```
[LdapLoginModule] authentication-first mode; SSL enabled
[LdapLoginModule] user provider: *$YourLDAPSERVERURL
[LdapLoginModule] tryFirstPass failed: javax.security.auth.login.FailedLoginException: No password was supplied
[LdapLoginModule] attempting to authenticate user: *$username
[LdapLoginModule] searching for entry belonging to user: *$username
[LdapLoginModule] authentication failed 
```

Parameters in the error:
* ***$YourLDAPSERVERURL**  this field will contain your LDAP server name
* ***$username** this field will contain the user name which you will try to authenticate.


