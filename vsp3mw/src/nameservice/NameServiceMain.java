package nameservice;

import mware_lib.NameService;

import java.io.IOException;

/**
 * Created by Swaneet on 31.05.2015.
 */
public class NameServiceMain extends Thread {
    public static final int PORT = 54321;
    public static final String HOST = "localhost";

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
