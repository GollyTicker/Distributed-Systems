package accessor_one;

import mware_lib.HasProxy;
import mware_lib.skeleton.HasSkeleton;
import mware_lib.skeleton.Skeleton;

import java.io.IOException;

/**
 * Created by sacry on 20/05/15.
 */
public abstract class ClassOneImplBase implements HasProxy, HasSkeleton {
    public abstract String methodOne(String param1, int param2)
            throws SomeException112;

    public static ClassOneImplBase narrowCast(Object rawObjectRef) {
        return (ClassOneImplBase) rawObjectRef;
    }

    @Override
    public Class<?> getProxyClass() {
        return ClassOneProxy.class;
    }

    @Override
    public <A> Skeleton<A> startSkeleton(int port, A o) throws IOException {
        return (Skeleton<A>) new ClassOneSkeleton(port,(ClassOneImplBase)o);
    }
}
