package com.ibm.clientengineering.mq.samples;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class Config {

    public final static String QMGRNAME = "AMSQMGR";
    public final static String QUEUE = "AMS.QLOCAL";
    public static String CCDT_LOCATION = "";

    public static void setupEnv() throws IOException {

        //Get the properties file location (main/resources/mq-config.properties)
        String propsLocation = System.getenv("PROPS_LOCATION");
        InputStream input;

        if(propsLocation != null && !propsLocation.equals("")) input = new FileInputStream(propsLocation);
        else input = Config.class.getClassLoader().getResourceAsStream("mq-config.properties");

        if (input == null) {
            System.out.println("WARN: unable to find mq-config.properties");
            return;
        }

        //Loading properties file
        Properties prop = new Properties();
        prop.load(input);

        //Importing variables from properties file
        CCDT_LOCATION = prop.getProperty("ccdt_location");
    }

    public static void setupTruststore() {
        System.setProperty("javax.net.ssl.trustStore", "./02-cert-generation/certs/ams-ca.jks" );
        System.setProperty("javax.net.ssl.keyStore", "./02-cert-generation/certs/ams-client.jks" );
        System.setProperty("javax.net.ssl.keyStorePassword", "passw0rd" );
        System.setProperty("com.ibm.mq.cfg.useIBMCipherMappings", "false");
    }
}
