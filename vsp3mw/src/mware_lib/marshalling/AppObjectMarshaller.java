package mware_lib.marshalling;

import accessor_one.SomeException110;
import java.util.ArrayList;
import java.util.Arrays;

import static mware_lib.Utils.checkPre;

/**
 * Created by Swaneet on 27.05.2015.
 */
public class AppObjectMarshaller {

    private static String SEP = ";";

    private static String APPOBJECT = "appobject";
    // "AppObject;$type;$objString"

    public static String marshall(Object o) throws MarshallingException {
        try {
            // check that type is in typeMapping
            String type = TypeMapping.getTypeName(o);
            String objStr =  (o == null) ? "null" : o.toString();
            return APPOBJECT + SEP + type + SEP + objStr;
        } catch (Exception e) {
            throw new MarshallingException("Invalid input: " + o.toString(),e);
        }
    }

    public static Object demarshall(String a) throws DemarshallingException {
        try {
            String[] strs = a.split(SEP);
            String appObject = strs[0];
            checkPre(appObject.equals(APPOBJECT),"AppObject expected, but got: " + appObject);
            String type = strs[1];
            String objStr = strs.length > 2 ? strs[2] : "";
            Class<?> cls = TypeMapping.getType(type);
            return TypeMapping.fromString(objStr, cls);
        } catch (Exception e) {
            throw new DemarshallingException("Invalid input: " + a, e);
        }
    }



    public static void main(String[] args) throws Exception {
        ArrayList<Object> objs = new ArrayList<>(
                Arrays.asList("myStr", "", new Integer(5), new Double(5), null,
                        new SomeException110("bla"),
                        new ArrayIndexOutOfBoundsException("klösd"),
                        new IndexOutOfBoundsException(),
                        new IndexOutOfBoundsException("du")
                )
        );
        ArrayList<String> marshalled = new ArrayList<>();
        ArrayList<Object> demarshalled = new ArrayList<>();
        for(Object obj : objs){
            String s = marshall(obj);
            Object o = demarshall(s);
            marshalled.add(s);
            demarshalled.add(o);
            System.out.println(o != null ? o.equals(obj) : obj == null);
            System.out.println(obj);
            System.out.println(o);
        }

    }
}
