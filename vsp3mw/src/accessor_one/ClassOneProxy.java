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
public class ClassOneProxy extends ClassOneImplBase {

    /*
        String methodOne(String param1, int param2) throws SomeException112;
    */

    public static String METHODONE = "methodOne";

    private int port;
    private String host;

    public ClassOneProxy(String host, int port) throws IOException {
        this.host = host;
        this.port = port;
    }

    @Override
    public String methodOne(String param1, int param2) throws SomeException112 {
        try {
            log(this, "ClassOneProxy.methodOne(" + param1 + "," + param2 + ")");
            Method method = new Method(METHODONE, new Object[]{param1, param2});
            String response = RemoteMethodInvocation.remoteMethodInvocation(method, this.host, this.port);

            if (ReturnMarshaller.isReturn(response)) {
                String res = String.valueOf(ReturnMarshaller.demarshall(response));
                return res;
            } else if (ErrorMarshaller.isException(response)) {
                Exception e = ErrorMarshaller.demarshall(response);
                if (e instanceof accessor_two.SomeException112)
                    throw (SomeException112) e;
            }
        } catch (SomeException112 e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return "";
    }
}
