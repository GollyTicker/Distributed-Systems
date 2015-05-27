package mware_lib.marshalling;

import com.sun.xml.internal.ws.handler.ClientMessageHandlerTube;

/**
 * Created by sacry on 27/05/15.
 */
public class MethodMarshaller extends AbstractMarshaller {

    public static String marshall(Method method) {
        return gson.toJson(method);
    }

    public static Method unmarshall(String json, Class<Method> clazz) {
        return gson.fromJson(json, clazz);
    }

    public static void main(String[] args) {
        Method myMethod = new Method("reference", "doubleBy", new Object[]{2, 3});
        String js = MethodMarshaller.marshall(myMethod);
        System.out.println(js);
        Method newMethod = MethodMarshaller.unmarshall(js, Method.class);
        System.out.println(newMethod.toString());
    }
}
