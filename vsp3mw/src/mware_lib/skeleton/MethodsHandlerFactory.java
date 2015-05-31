package mware_lib.skeleton;

import mware_lib.marshalling.Method;
import mware_lib.marshalling.MethodMarshaller;
import mware_lib.tcp.Connection;

import java.util.List;

import static mware_lib.Logger.log;
import static mware_lib.Utils.checkPre;

public class MethodsHandlerFactory {
    public static <A> MethodsHandler<A> fromMethod(String[] methodNames,List<SingleMethod<A>> methods) {
        return (A obj,Connection c) -> {
            try {
                String in = c.receive();
                Method method = MethodMarshaller.demarshall(in);
                log(obj,"MethodHandler<"+obj.getClass().getSimpleName()+">: " + method);
                String response = "";
                for(int i = 0; i < methodNames.length; i++) {
                    String methodName = methodNames[i];
                    if(method.isMethod(methodName)){
                        response = methods.get(i).call(obj,method.params);
                    }
                }
                if (response.isEmpty()) {
                    checkPre(false, "Unknown Method: " + method.methodName);
                }
                c.send(response);
                c.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        };
    }
}
