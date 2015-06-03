package mware_lib.skeleton;

import java.io.IOException;

/**
 * Created by networker on 03/06/15.
 */
public interface HasSkeleton {
    <A> Skeleton<A> startSkeleton(int port, A o) throws IOException;
}
