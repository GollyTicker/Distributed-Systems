package mware_lib.marshalling;

import accessor_one.SomeException110;

import java.util.ArrayList;
import java.util.Arrays;

import static mware_lib.Utils.checkPre;

/**
 * Created by Swaneet on 27.05.2015.
 */
public class ErrorMarshaller {

    private static String SEP = ";";
    private static String EXCEPTION = "exception";
    private static int EXCEPTION_SLICE = (EXCEPTION + SEP).length();

    // "exception;appobject;$type;$objString"

    public static String marshall(Object o) throws MarshallingException {
        try {
            return EXCEPTION + SEP + AppObjectMarshaller.marshall(o);
        } catch (Exception e) {
            throw new MarshallingException("Invalid input: " + o.toString(),e);
        }
    }

    public static Exception demarshall(String a) throws DemarshallingException {
        try {
            String[] parts = a.split(SEP);
            checkPre(parts[0].equals(EXCEPTION), "Expected exception message but got: " + a);
            String appObj = a.substring(EXCEPTION_SLICE);
            Object obj = AppObjectMarshaller.demarshall(appObj);
            checkPre(obj instanceof Exception, "Expected Exception, but got" + obj.getClass());
            return ((Exception) obj);
        } catch (Exception e) {
            throw new DemarshallingException("Invalid input: " + a, e);
        }
    }

    public static boolean isException(String val){
        return val.startsWith(EXCEPTION);
    }
}
