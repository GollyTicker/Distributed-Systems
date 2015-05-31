package mware_lib;

import java.io.IOException;

public class ObjectBroker {

    public static ObjectBroker init(String serviceHost, int listenPort, boolean debug) throws IOException{
        NameService nsProxy = new NameServiceProxy(serviceHost, listenPort);
        return new ObjectBroker(serviceHost, listenPort, nsProxy, debug);
    }

    private String serviceHost;
    private int listenPort;
    private boolean debug;
    private NameService nsProxy;

    public ObjectBroker(String serviceHost, int listenPort, NameService nsProxy, boolean debug) {
        this.serviceHost = serviceHost;
        this.listenPort = listenPort;
        this.debug = debug;
        this.nsProxy = nsProxy;
    }

    public NameService getNameService() {
        return this.nsProxy;
    }

    public void shutDown() {
    }
}