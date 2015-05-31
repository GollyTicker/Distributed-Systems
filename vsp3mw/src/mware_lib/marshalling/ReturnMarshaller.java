package mware_lib.marshalling;


import static mware_lib.Utils.checkPre;

/**
 * Created by Swaneet on 27.05.2015.
 */
public class ReturnMarshaller {

    private static String SEP = ";";
    private static String RETURN = "return";
    private static int RETURN_SLICE = (RETURN + SEP).length();

    // "return;appobject;$type;$objString"

    public static String marshall(Object o) throws MarshallingException {
        try {
            return RETURN + SEP + AppObjectMarshaller.marshall(o);
        } catch (Exception e) {
            throw new MarshallingException("Invalid input: " + o.toString(),e);
        }
    }

    public static Object demarshall(String a) throws DemarshallingException {
        try {
            String[] parts = a.split(SEP);
            checkPre(parts[0].equals(RETURN), "Expected return but got: " + a);
            String appObj = a.substring(RETURN_SLICE);
            return AppObjectMarshaller.demarshall(appObj);
        } catch (Exception e) {
            throw new DemarshallingException("Invalid input: " + a, e);
        }
    }

    public static boolean isReturn(String val){
        return val.startsWith(RETURN);
    }

}
