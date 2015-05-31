package accessor_two;

import mware_lib.marshalling.ErrorMarshaller;
import mware_lib.marshalling.ReturnMarshaller;
import mware_lib.RemoteMethodInvocation;

import java.io.IOException;

import static mware_lib.Logger.log;
import static mware_lib.Utils.checkPre;

/**
 * Created by Swaneet on 31.05.2015.
 */
public class ClassOneProxy extends ClassOneImplBase {

    /*
        double methodOne(String param1, double param2) throws SomeException112

        double methodTwo(String param1, double param2) throws SomeException112, someException304
    */

    public static String METHODONE = "methodOne";
    public static String METHODTWO = "methodTwo";

    private int port;
    private String host;

    public ClassOneProxy(String host, int port) throws IOException {
        this.host = host;
        this.port = port;
    }

    @Override
    public double methodOne(String param1, double param2) throws SomeException112 {
        try {
            log(this,"ClassOneProxy.methodOne(" + param1 + "," + param2 + ")");
            String response = RemoteMethodInvocation.remoteMethodInvocation(
                    METHODONE,
                    new Object[]{param1, param2},
                    this.host,
                    this.port
            );

            if (ReturnMarshaller.isReturn(response)) {
                double res = ((Double)ReturnMarshaller.demarshall(response)).doubleValue();
                return res;
            } else if (ErrorMarshaller.isException(response)) {
                Exception e = ErrorMarshaller.demarshall(response);
                if (e instanceof SomeException112)
                    throw (SomeException112)e;
            }
        } catch (SomeException112 e){
            throw e;
        }  catch (Exception e) {
            throw new RuntimeException(e);
        }
        return 0;
    }

    @Override
    public double methodTwo(String param1, double param2) throws SomeException112, SomeException304 {
        try {
            log(this,"ClassOneProxy.methodTwo(" + param1 + "," + param2 + ")");

            String response = RemoteMethodInvocation.remoteMethodInvocation(
                    METHODTWO,
                    new Object[]{param1, param2},
                    this.host,
                    this.port
            );

            if (ReturnMarshaller.isReturn(response)) {
                double res = ((Double)ReturnMarshaller.demarshall(response)).doubleValue();
                return res;
            } else if (ErrorMarshaller.isException(response)) {
                Exception e = ErrorMarshaller.demarshall(response);
                if (e instanceof SomeException112)
                    throw (SomeException112)e;
                if (e instanceof SomeException304)
                    throw (SomeException304)e;
            }
        } catch (SomeException112 e){
            throw e;
        } catch (SomeException304 e){
            throw e;
        }  catch (Exception e) {
            throw new RuntimeException(e);
        }
        return 0;
    }
}
