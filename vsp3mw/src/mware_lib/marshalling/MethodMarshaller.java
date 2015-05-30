package mware_lib.marshalling;

import accessor_one.SomeException110;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import static mware_lib.Utils.checkPre;

/**
 * Created by sacry on 27/05/15.
 */
public class MethodMarshaller {


    static String METHOD = "method";
    private static String PARAMS_SEP = "#";
    private static String SEP = ";";

    // "method;$methodname;$arity;[appobject$type;$objString#..]"

    public static String marshall(String methodName, Object[] params) throws MarshallingException {
        try {
            return METHOD + SEP + methodName + SEP + params.length + SEP + paramsString(params);
        } catch (Exception e) {
            throw new MarshallingException("Invalid input: " + methodName, e);
        }
    }

    // "method;$methodname;$arity;[appobject$type;$objString#..]"
    public static Method demarshall(String a) throws DemarshallingException {
        try {
            String[] strs = a.split(SEP);
            String isMethod = strs[0];
            checkPre(isMethod.equals(METHOD),"Method expected, but got: " + isMethod);

            String methodName = strs[1];
            int arity = Integer.parseInt(strs[2]);
            Object[] params = new Object[arity];

            if (arity > 0) {
                int head = a.indexOf("[");
                String paramStr = a.substring(head + 1,a.length() - 1);
                String[] apobjs = paramStr.split(PARAMS_SEP);
                checkPre(arity == apobjs.length, "Parsed wrong arity in params: " + paramStr);

                for(int i = 0; i < arity; i++) {
                    params[i] = AppObjectMarshaller.demarshall(apobjs[i]);
                }
            }
            return new Method(methodName, params);
        } catch (Exception e) {
            throw new DemarshallingException("Invalid input: " + a, e);
        }
    }

    private static String paramsString(Object[] params) throws MarshallingException {
        ArrayList<String> accu = new ArrayList<>();
        for(int idx = 0; idx < params.length; idx++){
            accu.add(AppObjectMarshaller.marshall(params[idx]));
        }
        return "[" + String.join(PARAMS_SEP, accu) + "]";
    }

    private static class Method {

        public String methodName;
        public Object[] params;

        public Method(String methodName, Object[] params) {
            this.methodName = methodName;
            this.params = params;
        }

        @Override
        public String toString() {
            return "Method{" +
                    "methodName='" + methodName + '\'' +
                    ", params=" + Arrays.toString(params) +
                    '}';
        }
    }

    public static void main(String[] args) throws Exception {
        HashMap<String, Object[]> methods = new HashMap<>();
        methods.put("a", new Object[]{"b", new Double(6.2)});
        methods.put("add", new Object[]{new Integer(5), new SomeException110("abc")});
        methods.put("bla", new Object[]{});
        ArrayList<String> marshalled = new ArrayList<>();
        for(Map.Entry<String, Object[]> e : methods.entrySet()){
            String s = marshall(e.getKey(), e.getValue());
            marshalled.add(s);
            System.out.println("Marshalled: " + s);
            System.out.println("Demarshalled: " + demarshall(s));
        }
    }
}
