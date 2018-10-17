# JRE remote monitoring configuration
=======
## General description

The JAVA applications are running on JAVA Virtual Machine (JVM). The JVM has been designed that via a JAVA Management Extensions (JMX) agent it can be monitored. This means that with a client application such as JConsole or JAVA Mission Control (JMC) a developer can connect to the local/remote enironment's JVM and extract useful information about the developed application. In nutshells its like an application insights for JAVA applications to see whats going on under the hood as your code is running. To enable the remote monitoring features you have to specify additional JAVA command line arguments. In this repository you will find the neccessary command line arguments which are needed for connecting your monitoring console to the JMX agent. 

For better overview and simplicity reasons I'm going to use the Tomcat way as an example how you can extend the command line arguments list. When you start the Tomcat application server in tomcat home bin directory you can create setenv.sh file where you can apply extra command line arguments. If this file exists there it will automatically executed during the startup. You will see in repositories setenv.sh the following lines: **"export CATALINA_OPTS="$CATALINA_OPTS -D$YourArgumentName=$value"**. As you start the tomcat you specify the starting command line arguments in the **"CATALINA_OPTS"** environment variable and with those lines you just extend the environment variables list. In case you prefer to do it with one line as you start your application you just simply list the arguments space separated after each other. In the example line you the **"$YourArgumentName"** stands for your the JAVA argument name and **"$value"** stands for the actual value of the argument.

For some command line arguments the JAVA framework allows you to create group them into a properties file. The values setted from the properties files are going to be hidden as you grep the running proccess. This is handy if you have to include the passwords for SSL and for the trusted store. 

