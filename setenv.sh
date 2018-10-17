#! /bin/sh

# ##################################
# Oracle JAVA specific
# These features are Oracle JAVA specific. This is how you enable the commercial features .

export CATALINA_OPTS="$CATALINA_OPTS -XX:+UnlockCommercialFeatures"

# In case you want to enable flight recording (record the behaviour of the JVM) you can do it like this.
export CATALINA_OPTS="$CATALINA_OPTS -XX:+FlightRecorder"

# Please be aware if your JAVA application is running by a service user then you will run into some permission issues. Here I mean that usually service users are restricted to create files. 
# To avoid the permission issues create a read-write directory for the flight records. In my case it was living under the "/opt/flight-recording" folder.
export CATALINA_OPTS="$CATALINA_OPTS -XX:FlightRecorderOptions=disk=true,repository=/opt/flight-recording,settings=default"
# ##################################

export CATALINA_OPTS="$CATALINA_OPTS -Djava.awt.headless=true" 
export CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote"

# The command line arguments for "com.sun.management.jmxremote" can be extracted into a properties file. Under the /java_opts folder you can find the "management.properties" file.
# please note that in the "management.properties" file you will find additional argument extraction to properties file. For example the SSL settings. 
export CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.config.file=/opt/java_opts/management.properties"

# The hostname plays an important role in the JMX configuration. As you establish the connection with the JMX agent it checks this value and allows you to connect only if the connection name or ip matches.
# In case you don't specify a value for this paramater the JVM will set it as you IP addresss.
# IF you want to establis the connection to JMX via SSL you need to put your hostname with domain name
export CATALINA_OPTS="$CATALINA_OPTS -Djava.rmi.server.hostname=$IP_OR_HOSTNAME_WITH_DOMAIN"


# ##################################
# LDAP Login module
# If you want to use LDAP authentication for JMX access you have to specify an LDAP login module
# Please note that the LDAP authentication works only if you specify which block you want to use from the configuration. It takes the value from "com.sun.management.jmxremote.login.config". More description in management.properties file.

# single role check
#export CATALINA_OPTS="$CATALINA_OPTS -Djava.security.auth.login.config=/opt/jmx_access/single_role_check.config"

# multiple role check
# Since the setting is going to be mostly the same with the single role. This will be less detailed
#export CATALINA_OPTS="$CATALINA_OPTS -Djava.security.auth.login.config=/opt/jmx_access/multi_role_check.config"
# ##################################