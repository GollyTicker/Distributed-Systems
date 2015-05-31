package mware_lib;

import accessor_two.ClassOneImplBase;
import accessor_two.ClassOneProxy;
import accessor_two.ClassOneSkeleton;
import mware_lib.marshalling.TypeMapping;
import mware_lib.tcp.Server;
import java.net.Inet4Address;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by Swaneet on 31.05.2015.
 */
public class ReferenceService extends NameService {
    private NameService ns;
    private Map<Object,Object> skeletonMapping = new HashMap<>();
    private Map<Object,Object> proxyMapping = new HashMap<>();
    private static String SEP = ":";

    // ObjectReference: "$host:$port:$class"

    public ReferenceService(NameService ns) {
        this.ns = ns;
    }

    @Override
    public void rebind(Object servant, String name) {
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
            String objectReference = host + SEP + port + SEP + servant.getClass();
            ns.rebind(objectReference,name);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }

    }

    @Override
    public Object resolve(String name) {
        try {
            String objectReference = (String) ns.resolve(name);
            String[] strs = objectReference.split(SEP);
            String host = strs[0];
            int port = Integer.parseInt(strs[1]);
            Class<?> cls = Class.forName(strs[2]);
            Object proxy = null;
            if(TypeMapping.isSubClassOf(cls,ClassOneImplBase.class)) {
                proxy = new ClassOneProxy(host,port);
                proxyMapping.put(name,proxy);
            } else {
                // andere fälle
            }
            return proxy;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
