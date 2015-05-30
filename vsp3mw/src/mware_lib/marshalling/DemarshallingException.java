package mware_lib.marshalling;

/**
 * Created by sacry on 30/05/15.
 */
public class DemarshallingException extends Exception {
    public DemarshallingException(String msg,Exception e) {
        super(msg + ", " + e.toString() + " - " + e.getMessage());
    }
}
