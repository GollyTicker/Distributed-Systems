package mware_lib;

import accessor_two.ClassOneImplBase;
import accessor_two.ClassOneSkeleton;
import mware_lib.marshalling.*;
import mware_lib.tcp.Client;
import java.io.IOException;
import static mware_lib.Logger.*;
/**
 * Created by sacry on 30/05/15.
 */
public class NameServiceProxy extends NameService {
    /*
    void rebind(Object servant, String name) -> "rebind"

    Object resolve(String name) -> "resolve"
    * */

    public static String REBIND = "rebind";
    public static String RESOLVE = "resolve";

    private int port;
    private String host;

    public NameServiceProxy(String host, int port) throws IOException {
        this.host = host;
        this.port = port;
    }

    @Override
    public void rebind(Object servant, String name) {
        try {
            log(this,"NameServiceProxy.rebind(" + servant + "," + name + ")");

            String objectReference = ReferenceService.createSkeleton(servant,name);

            Method method = new Method(REBIND, new Object[]{objectReference, name});
            String response = RemoteMethodInvocation.remoteMethodInvocation(method, this.host, this.port);


            if (ReturnMarshaller.isReturn(response)) {
                ReturnMarshaller.demarshall(response);
            } else if (ErrorMarshaller.isException(response)) {
                ErrorMarshaller.demarshall(response);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public Object resolve(String name) {
        try {
            log(this,"NameServiceProxy.resolve("+ name + ")");
            Method method = new Method(RESOLVE, new Object[]{name});
            String response = RemoteMethodInvocation.remoteMethodInvocation(method, this.host, this.port);

            log(this, "NameServiceProxy resolved:" + name + " -> " + response);
            if (ReturnMarshaller.isReturn(response)) {
                String objectReference = (String) ReturnMarshaller.demarshall(response);
                Object objProxy = ReferenceService.createProxy(objectReference);
                return objProxy;
            } else if (ErrorMarshaller.isException(response)) {
                throw ErrorMarshaller.demarshall(response);
            } else {
                return null;
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }

    }
}
