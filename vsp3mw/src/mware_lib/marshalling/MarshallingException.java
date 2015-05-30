package mware_lib.marshalling;

/**
 * Created by sacry on 30/05/15.
 */
public class MarshallingException extends Exception{
    public MarshallingException(String msg, Exception e) {
        super(msg + ", " + e.toString() + " - " + e.getMessage());
    }
}
