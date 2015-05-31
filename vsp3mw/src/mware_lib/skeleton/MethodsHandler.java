package mware_lib.skeleton;

import mware_lib.tcp.Connection;

/**
 * Created by Swaneet on 31.05.2015.
 */
public interface MethodsHandler<A> {
    void handleMethod(A obj,Connection c);
}

