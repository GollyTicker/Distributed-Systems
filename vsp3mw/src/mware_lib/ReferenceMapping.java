package mware_lib;

import mware_lib.marshalling.TypeMapping;
import mware_lib.skeleton.HasSkeleton;
import mware_lib.skeleton.Skeleton;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.util.HashMap;
import java.util.Map;

import static mware_lib.Logger.log;
import static mware_lib.Utils.checkPre;

/**
 * Created by sacry on 31/05/15.
 */
public class ReferenceMapping {

    private static Map<Object, Skeleton<?>> skeletonMapping = new HashMap<>();
    private static Map<Object, Object> proxyMapping = new HashMap<>();

    public static void shutDown(){
        for(Map.Entry<Object, Skeleton<?>> e : skeletonMapping.entrySet()){
            e.getValue().shutDown();
        }
    }

    public static Object getProxy(String objectReference, Class<?> cls, String host, int port) throws Exception {
        Object proxy = null;
        if (TypeMapping.isSubClassOf(cls, HasProxy.class)) {
            Class<? extends HasProxy> hpclass = cls.asSubclass(HasProxy.class);
            proxy = hpclass.getDeclaredConstructor(String.class,Integer.class).newInstance(host,new Integer(port));
        }
        if (proxy != null)
            proxyMapping.put(objectReference, proxy);
        else
            checkPre(false, "Proxy ObjectReference not valid: " + objectReference);
        return proxy;
    }

    public static void addSkeleton(Object servant, int port) throws IOException {
        Skeleton<?> skeleton = null;
        if (TypeMapping.isSubClassOf(servant.getClass(), HasSkeleton.class)) {
            skeleton = ((HasSkeleton)servant).startSkeleton(port,servant);
        }
        if (skeleton != null)
            skeletonMapping.put(servant, skeleton);
        else
            checkPre(false, "Skeleton Servant not valid: " + servant.getClass());
    }

}
