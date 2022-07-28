package com.ibm.clientengineering.mq.samples;

import javax.jms.Connection;
import javax.jms.Destination;
import javax.jms.Message;
import javax.jms.MessageConsumer;
import javax.jms.Session;

import java.io.File;
import java.io.IOException;

import com.ibm.mq.jms.MQConnectionFactory;
import com.ibm.msg.client.wmq.WMQConstants;

public class Getter {
    public static void main(String[] args) throws IOException {

        Config.setupEnv();
        Config.setupTruststore();

        Connection connection = null;
        Session session = null;
        Destination destination = null;
        MessageConsumer consumer = null;

        try {
            File ccdtfile = new File(Config.CCDT_LOCATION);

            MQConnectionFactory cf = new MQConnectionFactory();
            cf.setCCDTURL(ccdtfile.toURI().toURL());
            cf.setQueueManager(Config.QMGRNAME);
            cf.setClientReconnectOptions(WMQConstants.WMQ_CLIENT_RECONNECT);

            connection = cf.createConnection("mqread","mqread");
            session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);

            destination = session.createQueue(Config.QUEUE);
            consumer = session.createConsumer(destination);

            connection.start();

            while (true) {
                Message message = consumer.receive();
                if (message != null) {
                    System.out.println(message.toString());
                }
            }
            // connection.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
}
