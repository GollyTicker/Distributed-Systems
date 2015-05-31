package accessor_two;

/**
 * Created by sacry on 20/05/15.
 */
public abstract class ClassOneImplBase {
    public abstract double methodOne(String param1, double param2)
            throws SomeException112;

    public abstract double methodTwo(String param1, double param2)
            throws SomeException112, SomeException304;

    public static ClassOneImplBase narrowCast(Object rawObjectRef) {
        return (ClassOneImplBase)rawObjectRef;
    }
}
