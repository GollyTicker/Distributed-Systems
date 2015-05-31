package mware_lib;

import mware_lib.marshalling.Method;
import mware_lib.marshalling.MethodMarshaller;
import mware_lib.marshalling.TypeMapping;
import mware_lib.tcp.Client;

import static mware_lib.Logger.log;

/**
 * Created by Swaneet on 31.05.2015.
 */
public class RemoteMethodInvocation {
    public static String remoteMethodInvocation(Method method,String host, int port) throws Exception{
        log("RMI", "RMI to " + host + ":" + port);
        Client client = new Client(host, port);
        String methodStr = MethodMarshaller.marshall(method);
        client.send(methodStr);
        String response = client.receive();
        client.close();
        return response;
    }
}
