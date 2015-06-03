package mware_lib.skeleton;

import mware_lib.tcp.Connection;
import mware_lib.tcp.Server;

import java.io.IOException;
import java.util.List;

import static mware_lib.Logger.log;

/**
 * Created by Swaneet on 31.05.2015.
 */
public abstract class Skeleton<A> {
    private int port;
    public abstract String[] methodsNames();
    public abstract List<SingleMethod<A>> methods();
    private Thread serverThread;

    public Skeleton(int port, A obj) throws IOException {
        this.port = port;
        MethodsHandler<A> methodsHandler = MethodsHandlerFactory.fromMethod(methodsNames(), methods());
        Runnable r = () -> {
            Server s = null;
            try {
                s = new Server(port);
                log(this,"Skeleton<"+obj.getClass().getSimpleName()+"> running at " + port);
                while(true) {
                    Connection c = s.getConnection();
                    new Thread(new Worker(obj,c, methodsHandler)).start();
                }
            } catch (Exception e1) {
                e1.printStackTrace();
                try{
                    s.shutdown();
                } catch (Exception e2) {
                    e2.printStackTrace();
                }
            }
        };
        this.serverThread = new Thread(r);
        this.serverThread.start();
    }

    public void shutDown(){
        this.serverThread.interrupt();
    }

    public class Worker<A> implements Runnable {
        private A obj;
        private Connection c;
        private MethodsHandler<A> methodsHandler;
        public Worker(A obj, Connection c, MethodsHandler<A> methodsHandler) {
            this.obj = obj;
            this.c = c;
            this.methodsHandler = methodsHandler;
        }

        @Override
        public void run() {
            methodsHandler.handleMethod(obj,c);
        }
    }

}

