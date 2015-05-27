package mware_lib.tcp;

import java.io.IOException;

/**
 * Created by Swaneet on 27.05.2015.
 */
public abstract class ThreadedServer extends Server {

    public ThreadedServer(int listenPort) throws IOException {
        super(listenPort);
    }

    public void startServer() throws IOException {
        while(true) {
            Connection c = getConnection();
            Runnable r = () -> runClient(c);
            new Thread(r).start();
        }
    }

    public abstract void runClient(Connection c);
}
