package accessor_two;

import mware_lib.marshalling.ErrorMarshaller;
import mware_lib.marshalling.Method;
import mware_lib.marshalling.MethodMarshaller;
import mware_lib.marshalling.ReturnMarshaller;
import mware_lib.tcp.Client;

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

            Client client = new Client(this.host, this.port);
            String method = MethodMarshaller.marshall(new Method(METHODONE, new Object[]{param1,param2}));
            client.send(method);
            String response = client.receive();
            client.close();

            if (ReturnMarshaller.isReturn(response)) {
                double res = ((Double)ReturnMarshaller.demarshall(response)).doubleValue();
                return res;
            } else if (ErrorMarshaller.isException(response)) {
                Exception e = ErrorMarshaller.demarshall(response);
                if (e instanceof SomeException112)
                    throw (SomeException112)e;
            } else {
                checkPre(false,"RMI Response was neither Return nor Exception: " + response);
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

            Client client = new Client(this.host, this.port);
            String method = MethodMarshaller.marshall(new Method(METHODTWO, new Object[]{param1,param2}));
            client.send(method);
            String response = client.receive();
            client.close();

            if (ReturnMarshaller.isReturn(response)) {
                double res = ((Double)ReturnMarshaller.demarshall(response)).doubleValue();
                return res;
            } else if (ErrorMarshaller.isException(response)) {
                Exception e = ErrorMarshaller.demarshall(response);
                if (e instanceof SomeException112)
                    throw (SomeException112)e;
                if (e instanceof SomeException304)
                    throw (SomeException304)e;
            } else {
                checkPre(false,"RMI Response was neither Return nor Exception: " + response);
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
