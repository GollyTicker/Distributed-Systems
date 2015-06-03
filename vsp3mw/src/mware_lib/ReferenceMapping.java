package mware_lib;

import accessor_two.ClassOneImplBase;
import accessor_two.ClassOneProxy;
import accessor_two.ClassOneSkeleton;
import mware_lib.marshalling.TypeMapping;
import mware_lib.skeleton.Skeleton;

import java.io.IOException;
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

    public static Object getProxy(String objectReference, Class<?> cls, String host, int port) throws IOException {
        Object proxy = null;
        if (TypeMapping.isSubClassOf(cls, accessor_one.ClassOneImplBase.class)) {
            proxy = new accessor_one.ClassOneProxy(host, port);
        } else if (TypeMapping.isSubClassOf(cls, accessor_one.ClassTwoImplBase.class)) {
            proxy = new accessor_one.ClassTwoProxy(host, port);
        } else if (TypeMapping.isSubClassOf(cls, accessor_two.ClassOneImplBase.class)) {
            proxy = new accessor_two.ClassOneProxy(host, port);
        }
        if (proxy != null)
            proxyMapping.put(objectReference, proxy);
        else
            checkPre(false, "Proxy ObjectReference not valid: " + objectReference);
        return proxy;
    }

    public static void addSkeleton(Object servant, int port) throws IOException {
        Skeleton<?> skeleton = null;
        if (TypeMapping.isSubClassOf(servant.getClass(), accessor_one.ClassOneImplBase.class)) {
            skeleton = new accessor_one.ClassOneSkeleton(port, (accessor_one.ClassOneImplBase) servant);
        } else if (TypeMapping.isSubClassOf(servant.getClass(), accessor_one.ClassTwoImplBase.class)) {
            skeleton = new accessor_one.ClassTwoSkeleton(port, (accessor_one.ClassTwoImplBase) servant);
        } else if (TypeMapping.isSubClassOf(servant.getClass(), accessor_two.ClassOneImplBase.class)) {
            skeleton = new accessor_two.ClassOneSkeleton(port, (accessor_two.ClassOneImplBase) servant);
        }
        if (skeleton != null)
            skeletonMapping.put(servant, skeleton);
        else
            checkPre(false, "Skeleton Servant not valid: " + servant.getClass());
    }

}
