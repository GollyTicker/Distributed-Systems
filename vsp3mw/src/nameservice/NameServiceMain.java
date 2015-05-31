package nameservice;

import mware_lib.NameService;

/**
 * Created by Swaneet on 31.05.2015.
 */
public class NameServiceMain {
    public final static int PORT = 54321;
    public final static String HOST = "localhost";

    public static void main(String[] args) throws Exception {
        startNameService();
    }

    public static void startNameService() throws Exception {
        NameService ns = new NameServiceImpl();
        NameServiceSkeleton nsSkel = new NameServiceSkeleton(PORT,ns);
        while (true)
            Thread.yield();
    }
}
