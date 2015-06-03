package mware_lib;

import mware_lib.tcp.Server;
import java.net.Inet4Address;

import static mware_lib.Logger.log;

/**
 * Created by Swaneet on 31.05.2015.
 */
public class ReferenceService {

    private static String SEP = ":";

    // ObjectReference: "$host:$port:$class"

    public static String createSkeleton(Object servant, String name) {
        try {
            int port = Server.newPort();
            ReferenceMapping.addSkeleton(servant, port);
            String host = Inet4Address.getLocalHost().getHostAddress();
            // geht cast immer? TODO:
            String proxyName = ((HasProxy)servant).getProxyClass().getTypeName();
            String objectReference = host + SEP + port + SEP + proxyName;
            return objectReference;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public static Object createProxy(String objectReference) {
        try {
            String[] strs = objectReference.split(SEP);
            String host = strs[0];
            int port = Integer.parseInt(strs[1]);
            log("", "Class: " + strs[2]);
            Class<?> cls = Class.forName(strs[2]);
            return ReferenceMapping.getProxy(objectReference, cls, host, port);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
