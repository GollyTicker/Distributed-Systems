package nameservice;

import mware_lib.NameService;

import java.io.IOException;
import java.net.Inet4Address;
import java.net.UnknownHostException;

/**
 * Created by Swaneet on 31.05.2015.
 */
public class NameServiceMain extends Thread {
    public static final int PORT = 54321;
    public static String HOST;

    static {
        try {
            HOST = Inet4Address.getLocalHost().getHostAddress();
        } catch (UnknownHostException e) {
            HOST = "";
            e.printStackTrace();
            System.exit(1);
        }
    }

    private NameService ns;
    private NameServiceSkeleton nsSkeleton;

    public NameServiceMain() throws IOException {
        ns = new NameServiceImpl();
        nsSkeleton = new NameServiceSkeleton(PORT, ns);
    }

    @Override
    public void run() {
        while (true)
            Thread.yield();
    }

    public static void main(String[] args) throws Exception {
        new Thread(new NameServiceMain()).start();
    }

}
