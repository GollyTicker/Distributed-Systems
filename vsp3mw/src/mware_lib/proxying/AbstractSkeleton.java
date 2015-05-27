package mware_lib.proxying;

import mware_lib.tcp.Connection;
import mware_lib.tcp.Server;
import mware_lib.tcp.ThreadedServer;

import java.io.IOException;
import static mware_lib.Logger.*;

/**
 * Created by Swaneet on 27.05.2015.
 */
public abstract class AbstractSkeleton {
    Server s;
    public AbstractSkeleton(int port) {
        try {
            s = new ThreadedServer(port) {
                @Override public void runClient(Connection c) {
                    runClient(c);
                }
            };
        } catch (IOException e) {
            log(this.getClass(),"Could not listen on Skeleton port.");
            e.printStackTrace();
        }
    }

    public abstract void runClient(Connection c) throws IOException;
}
