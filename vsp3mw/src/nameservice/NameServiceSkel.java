package nameservice;

import mware_lib.proxying.AbstractSkeleton;
import mware_lib.tcp.Connection;

import java.io.IOException;

/**
 * Created by Swaneet on 27.05.2015.
 */
public class NameServiceSkel extends AbstractSkeleton {

    NameServiceSkel(int port) {
        super(port);
    }

    @Override
    public void runClient(Connection c) throws IOException {
        String req = c.receive();
    }
}
