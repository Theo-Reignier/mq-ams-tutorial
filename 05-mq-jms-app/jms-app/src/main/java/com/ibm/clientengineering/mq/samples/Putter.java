package com.ibm.clientengineering.mq.samples;

import java.util.Date;

import javax.jms.Connection;
import javax.jms.Destination;
import javax.jms.Message;
import javax.jms.MessageProducer;
import javax.jms.Session;

import java.io.File;
import java.io.IOException;

import com.ibm.mq.jms.MQConnectionFactory;
import com.ibm.msg.client.wmq.WMQConstants;

public class Putter {
    public static void main(String[] args) throws IOException {

        Config.setupEnv();
        Config.setupTruststore();

        Connection connection = null;
        Session session = null;
        Destination destination = null;
        MessageProducer producer = null;

        try {
            File ccdtfile = new File(Config.CCDT_LOCATION);

            MQConnectionFactory cf = new MQConnectionFactory();
            cf.setCCDTURL(ccdtfile.toURI().toURL());
            cf.setQueueManager(Config.QMGRNAME);
            cf.setClientReconnectOptions(WMQConstants.WMQ_CLIENT_RECONNECT);
            
            connection = cf.createConnection("mqwrite","mqwrite");
            session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);

            destination = session.createQueue(Config.QUEUE);
            producer = session.createProducer(destination);

            connection.start();

            while (true) {
                String messagestring = new Date().toString();
                Message message = session.createTextMessage(messagestring);
                producer.send(message);

                System.out.println("sent <" + messagestring + ">");
                Thread.sleep(2000);
            }
            // connection.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
}
