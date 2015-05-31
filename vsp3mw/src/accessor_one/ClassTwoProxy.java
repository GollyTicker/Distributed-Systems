package accessor_one;

import mware_lib.RemoteMethodInvocation;
import mware_lib.marshalling.ErrorMarshaller;
import mware_lib.marshalling.Method;
import mware_lib.marshalling.ReturnMarshaller;

import java.io.IOException;

import static mware_lib.Logger.log;

/**
 * Created by sacry on 31/05/15.
 */
public class ClassTwoProxy extends ClassTwoImplBase {

    /*
        int methodOne(double param1) throws SomeException110;

        double methodTwo() throws SomeException112;
    */

    public static String METHODONE = "methodOne";
    public static String METHODTWO = "methodTwo";

    private int port;
    private String host;

    public ClassTwoProxy(String host, int port) throws IOException {
        this.host = host;
        this.port = port;
    }

    @Override
    public int methodOne(double param1) throws SomeException110 {
        try {
            log(this, "ClassTwoProxy.methodOne(" + param1 + ")");
            Method method = new Method(METHODONE, new Object[]{param1});
            String response = RemoteMethodInvocation.remoteMethodInvocation(method, this.host, this.port);

            if (ReturnMarshaller.isReturn(response)) {
                Object ret = ReturnMarshaller.demarshall(response);
                return (int) ret;
            } else if (ErrorMarshaller.isException(response)) {
                Exception e = ErrorMarshaller.demarshall(response);
                if (e instanceof SomeException110)
                    throw (SomeException110) e;
            }
        } catch (SomeException110 e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return 0;
    }

    @Override
    public double methodTwo() throws SomeException112 {
        try {
            log(this, "ClassTwoProxy.methodTwo()");
            Method method = new Method(METHODTWO, new Object[]{});
            String response = RemoteMethodInvocation.remoteMethodInvocation(method, this.host, this.port);

            if (ReturnMarshaller.isReturn(response)) {
                String s = String.valueOf(ReturnMarshaller.demarshall(response));
                return Double.parseDouble(s);
            } else if (ErrorMarshaller.isException(response)) {
                Exception e = ErrorMarshaller.demarshall(response);
                if (e instanceof SomeException112)
                    throw (SomeException112) e;
            }
        } catch (SomeException112 e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return 0;
    }
}
