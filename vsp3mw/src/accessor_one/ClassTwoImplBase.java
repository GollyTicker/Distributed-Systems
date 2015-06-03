package accessor_one;

import mware_lib.HasProxy;
import mware_lib.skeleton.HasSkeleton;
import mware_lib.skeleton.Skeleton;

import java.io.IOException;

/**
 * Created by sacry on 20/05/15.
 */
public abstract class ClassTwoImplBase implements HasProxy,HasSkeleton {
    public abstract int methodOne(double param1) throws SomeException110;

    public abstract double methodTwo() throws SomeException112;

    public static ClassTwoImplBase narrowCast(Object rawObjectRef) {
        return (ClassTwoImplBase) rawObjectRef;
    }

    @Override
    public <A> Skeleton<A> startSkeleton(int port, A o) throws IOException {
        return (Skeleton<A>) new ClassTwoSkeleton(port,(ClassTwoImplBase)o);
    }

    @Override
    public Class<?> getProxyClass() {
        return ClassTwoProxy.class;
    }
}
