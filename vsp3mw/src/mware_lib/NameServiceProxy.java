package mware_lib;

import mware_lib.marshalling.*;
import mware_lib.tcp.Client;
import mware_lib.tcp.Connection;
import mware_lib.tcp.Server;

import java.io.IOException;

import static mware_lib.Utils.checkPre;
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
            Client client = new Client(this.host, this.port);
            String rebindMethod = MethodMarshaller.marshall(REBIND, new Object[]{servant, name});
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
            String rebindMethod = MethodMarshaller.marshall(RESOLVE, new Object[]{name});
            client.send(rebindMethod);
            String response = client.receive();
            client.close();

            if (ReturnMarshaller.isReturn(response)) {
                return ReturnMarshaller.demarshall(response);
            } else if (ErrorMarshaller.isException(response)) {
                throw ErrorMarshaller.demarshall(response);
            } else {
                return null;
            }


        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }

    }
}
