package nameservice;

import mware_lib.NameService;
import mware_lib.marshalling.*;
import mware_lib.tcp.Connection;
import mware_lib.tcp.Server;

import java.io.IOException;
import java.lang.Object;

import static mware_lib.Logger.log;
import static mware_lib.Utils.checkPre;
import static mware_lib.NameServiceProxy.*;
/**
 * Created by Swaneet on 27.05.2015.
 */
public class NameServiceSkeleton {
    /*
    void rebind(Object servant, String name) -> "rebind"

    Object resolve(String name) -> "resolve"
    * */

    private int port;
    private NameService ns;

    public NameServiceSkeleton(int port, NameService ns) throws IOException {
        this.port = port;
        this.ns = ns;

        Runnable r = () -> {
            try {
                Server s =new Server(port);
                while(true) {
                    Connection c = s.getConnection();
                    new Thread(new Worker(ns,c)).start();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        };
        new Thread(r).start();
    }

    public static class Worker implements Runnable {
        private NameService ns;
        private Connection c;
        public Worker(NameService ns, Connection c){
            this.ns = ns;
            this.c = c;
        }

        @Override
        public void run() {
            try {
                String in = c.receive();
                Method method = MethodMarshaller.demarshall(in);
                log(this,"NameServiceskeleton: " + method);

                if (method.isMethod(REBIND)) {
                    Object servant = method.params[0];
                    String name = (String) method.params[1];
                    ns.rebind(servant, name);
                    String response = ReturnMarshaller.marshall(TypeMapping.VOID);
                    c.send(response);
                } else if (method.isMethod(RESOLVE)) {
                    String name = (String) method.params[0];
                    Object obj = ns.resolve(name);
                    String response = ReturnMarshaller.marshall(obj);
                    c.send(response);
                } else {
                    checkPre(false, "Unknown Method: " + method.methodName);
                }
                c.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }


}
