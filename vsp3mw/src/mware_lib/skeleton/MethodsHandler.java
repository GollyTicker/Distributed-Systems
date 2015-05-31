package mware_lib.skeleton;

import mware_lib.marshalling.Method;
import mware_lib.marshalling.MethodMarshaller;
import mware_lib.tcp.Connection;

import java.util.List;

import static mware_lib.Logger.log;
import static mware_lib.Utils.checkPre;

/**
 * Created by Swaneet on 31.05.2015.
 */
public interface MethodsHandler<A> {
    void handleMethod(A obj,Connection c);
}

