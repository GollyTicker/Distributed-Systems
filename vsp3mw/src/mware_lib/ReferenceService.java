package mware_lib;

import accessor_two.ClassOneImplBase;
import accessor_two.ClassOneProxy;
import accessor_two.ClassOneSkeleton;
import mware_lib.marshalling.TypeMapping;
import mware_lib.tcp.Server;
import java.net.Inet4Address;
import java.util.HashMap;
import java.util.Map;

import static mware_lib.Logger.log;

/**
 * Created by Swaneet on 31.05.2015.
 */
public class ReferenceService {
    private static Map<Object,Object> skeletonMapping = new HashMap<>();
    private static Map<Object,Object> proxyMapping = new HashMap<>();
    private static String SEP = ":";

    // ObjectReference: "$host:$port:$class"

    public static String createSkeleton(Object servant, String name) {
        try {
            int port = Server.newPort();
            Object skeleton = null;
            if (TypeMapping.isSubClassOf(servant.getClass(), ClassOneImplBase.class)) {
                skeleton = new ClassOneSkeleton(port,(ClassOneImplBase) servant);
            } else {
                // andere Objekte und ihre Bearbeitung
            }
            skeletonMapping.put(servant,skeleton);
            String host = Inet4Address.getLocalHost().getCanonicalHostName();
            String objectReference = host + SEP + port + SEP + servant.getClass().getTypeName();
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
            log("","Class: " + strs[2]);
            Class<?> cls = Class.forName(strs[2]);
            Object proxy = null;
            if(TypeMapping.isSubClassOf(cls, ClassOneImplBase.class)) {
                proxy = new ClassOneProxy(host,port);
                proxyMapping.put(objectReference,proxy);
            } else {
                // andere fälle
            }
            return proxy;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
