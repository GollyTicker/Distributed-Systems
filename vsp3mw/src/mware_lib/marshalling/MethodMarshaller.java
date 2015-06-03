package mware_lib.marshalling;

import java.util.ArrayList;

import static mware_lib.Utils.checkPre;

/**
 * Created by sacry on 27/05/15.
 */
public class MethodMarshaller {


    static String METHOD = "method";
    private static String PARAMS_SEP = "#";
    private static String SEP = ";";

    // "method;$methodname;$arity;[appobject$type;$objString#..]"

    public static String marshall(Method method) throws MarshallingException {
        try {
            return METHOD + SEP + method.methodName + SEP + method.params.length + SEP + paramsString(method.params);
        } catch (Exception e) {
            throw new MarshallingException("Invalid input: " + method.methodName, e);
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
}
