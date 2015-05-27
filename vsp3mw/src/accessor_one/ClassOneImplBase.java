package accessor_one;

/**
 * Created by sacry on 20/05/15.
 */
public abstract class ClassOneImplBase {
    public abstract String methodOne(String param1, int param2)
            throws SomeException112;
    public static ClassOneImplBase narrowCast(Object rawObjectRef) {return null;}
}
