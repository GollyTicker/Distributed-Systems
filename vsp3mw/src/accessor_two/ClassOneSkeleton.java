package accessor_two;

import mware_lib.NameService;
import mware_lib.marshalling.*;
import mware_lib.tcp.Connection;
import mware_lib.tcp.Server;

import java.io.IOException;

import static mware_lib.Logger.log;
import static mware_lib.Utils.checkPre;
import static accessor_two.ClassOneProxy.*;

/**
 * Created by sacry on 30/05/15.
 */
public class ClassOneSkeleton {

    /*
        double methodOne(String param1, double param2) throws SomeException112

        double methodTwo(String param1, double param2) throws SomeException112, SomeException304
    */

    private int port;
    private ClassOneImplBase cls;

    public ClassOneSkeleton(int port, ClassOneImplBase cls) throws IOException {
        this.port = port;
        Runnable r = () -> {
            try {
                Server s = new Server(port);
                log(this,"ClassOneSkeleton running at " + port);
                while(true) {
                    Connection c = s.getConnection();
                    new Thread(new Worker(cls,c)).start();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        };
        new Thread(r).start();
    }

    public static class Worker implements Runnable {
        private ClassOneImplBase cls;
        private Connection c;
        public Worker(ClassOneImplBase cls, Connection c){
            this.cls = cls;
            this.c = c;
        }

        @Override
        public void run() {
            try {
                String in = c.receive();
                Method method = MethodMarshaller.demarshall(in);
                log(this,"ClassOneSkeleton: " + method);

                if (method.isMethod(METHODONE)) {
                    // double methodOne(String param1, double param2) throws SomeException112
                    String param1 = (String) method.params[0];
                    double param2 = ((Double) method.params[1]).doubleValue();
                    String response = "";
                    try {
                        double res = cls.methodOne(param1,param2);
                        response = ReturnMarshaller.marshall(new Double(res));
                    }
                    catch (SomeException112 e){
                        response = ErrorMarshaller.marshall(e);
                    }
                    c.send(response);
                } else if (method.isMethod(METHODTWO)) {
                    // double methodTwo(String param1, double param2) throws SomeException112, SomeException304
                    String param1 = (String) method.params[0];
                    double param2 = ((Double) method.params[1]).doubleValue();
                    String response = "";
                    try {
                        double res = cls.methodTwo(param1,param2);
                        response = ReturnMarshaller.marshall(new Double(res));
                    }
                    catch (SomeException112 e) {
                        response = ErrorMarshaller.marshall(e);
                    }
                    catch (SomeException304 e) {
                        response = ErrorMarshaller.marshall(e);
                    }
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
