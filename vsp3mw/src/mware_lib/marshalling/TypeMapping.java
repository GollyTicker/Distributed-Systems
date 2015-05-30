package mware_lib.marshalling;

import java.util.HashMap;
import java.util.Map;

import static mware_lib.Utils.checkPre;

/**
 * Created by sacry on 30/05/15.
 */
public class TypeMapping {

    private static Map<Class<?>, String> typeMapping = new HashMap<>();
    private static Map<String, Class<?>> inverseTypeMapping = new HashMap<>();

    public final static Object VOID = "void";

    static {
        // + Exceptions mit einem oder keinem String-Argument im Construktor und die ein ":" im .toString enthalten.
        typeMapping.put(Void.class, Void.class.getTypeName());
        typeMapping.put(Integer.class, Integer.class.getTypeName());
        typeMapping.put(Double.class, Double.class.getTypeName());
        typeMapping.put(String.class, String.class.getTypeName());
        typeMapping.put(Null.class, Null.class.getTypeName());
        for (Map.Entry<Class<?>, String> e : typeMapping.entrySet()) {
            inverseTypeMapping.put(e.getValue(), e.getKey());
        }
    }

    public static Class<?> getType(String s) throws Exception {
        if (inverseTypeMapping.containsKey(s)) {
            return inverseTypeMapping.get(s);
        } else {
            Class<?> expClass = Class.forName(s);
            checkPre(isException(expClass), "Expected subtype of Exception, but was: " + s);
            return expClass;
        }
    }

    private static boolean isException(Class<?> cls) {
        return Exception.class.isAssignableFrom(cls);
    }

    public static String getTypeName(Object o) {
        Object type = null;
        if (o == null) {
            type = Null.class;
        } else if (o instanceof Exception) {
            return o.getClass().getTypeName();
        } else {
            type = o.getClass();
        }
        checkPre(typeMapping.containsKey(type), "Type was not handled by Null, Exception or typeMapping, type: " + type);
        return typeMapping.get(type);
    }

    public static Object fromString(String objStr, Class<?> cls) throws Exception{
        if (cls.equals(Void.class))
            return VOID;
        else if (cls.equals(String.class))
            return objStr;
        else if (cls.equals(Integer.class))
            return Integer.parseInt(objStr);
        else if (cls.equals(Double.class))
            return Double.parseDouble(objStr);
        else if (cls.equals(Null.class))
            return null;
        else if (isException(cls))
            return getException(objStr, cls);
        else {
            // type mapping veraltet, oder unerwarteter typ.
            checkPre(false, "Cannot create object from class. class = " + cls + ", objStr = " + objStr);
            return null;
        }
    }

    private static Object getException(String objStr, Class<?> cls) throws Exception{
        int idx = objStr.indexOf(":");
        if(idx == -1) {
            return cls.newInstance();
        }
        String expMsg = objStr.substring(idx + 2);
        return cls.getConstructor(String.class).newInstance(expMsg);
    }

    public static class Null {

    }

    public static void main(String[] args) {
    }

}
