package accessor_two;

import mware_lib.HasProxy;
import mware_lib.skeleton.HasSkeleton;
import mware_lib.skeleton.Skeleton;

import java.io.IOException;

/**
 * Created by sacry on 20/05/15.
 */
public abstract class ClassOneImplBase implements HasProxy,HasSkeleton {
    public abstract double methodOne(String param1, double param2)
            throws SomeException112;

    public abstract double methodTwo(String param1, double param2)
            throws SomeException112, SomeException304;

    public static ClassOneImplBase narrowCast(Object rawObjectRef) {
        return (ClassOneImplBase)rawObjectRef;
    }

    @Override
    public <A> Skeleton<A> startSkeleton(int port, A o) throws IOException {
        return (Skeleton<A>) new ClassOneSkeleton(port,(ClassOneImplBase)o);
    }

    @Override
    public Class<?> getProxyClass() {
        return ClassOneProxy.class;
    }
}
