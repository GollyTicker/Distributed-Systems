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
            Client client = new Client(this.host, this.port);
            String rebindMethod = MethodMarshaller.marshall(new Method(REBIND, new Object[]{objectReference, name}));
            client.send(rebindMethod);
            String response = client.receive();

            if (ReturnMarshaller.isReturn(response)) {
                ReturnMarshaller.demarshall(response);
            } else if (ErrorMarshaller.isException(response)) {
                ErrorMarshaller.demarshall(response);
            }

            client.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public Object resolve(String name) {
        try {
            log(this,"NameServiceProxy.resolve("+ name + ")");
            Client client = new Client(this.host, this.port);
            String resolveMethod = MethodMarshaller.marshall(new Method(RESOLVE, new Object[]{name}));
            client.send(resolveMethod);
            String response = client.receive();
            client.close();

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
