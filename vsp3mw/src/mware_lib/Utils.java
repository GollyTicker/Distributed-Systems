package mware_lib;

/**
 * Created by sacry on 20/05/15.
 */
public class Utils {

    private Utils(){}

    public static void checkPre(Boolean b) {
        checkPre(b,"");
    }

    public static void checkPre(Boolean b,String msg) {
        if (!b) {
            throw new IllegalArgumentException("Failed precondition: " + msg);
        }
    }
}
