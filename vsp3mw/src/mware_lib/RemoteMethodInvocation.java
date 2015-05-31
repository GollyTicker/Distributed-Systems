package mware_lib;

import mware_lib.marshalling.Method;
import mware_lib.marshalling.MethodMarshaller;
import mware_lib.marshalling.TypeMapping;
import mware_lib.tcp.Client;

/**
 * Created by Swaneet on 31.05.2015.
 */
public class RemoteMethodInvocation {
    public static String remoteMethodInvocation(String methodName,Object[] params,String host, int port) throws Exception{
        Client client = new Client(host, port);
        String method = MethodMarshaller.marshall(new Method(methodName, params));
        client.send(method);
        String response = client.receive();
        client.close();
        return response;
    }
}
