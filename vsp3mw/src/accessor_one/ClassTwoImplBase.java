package accessor_one;

/**
 * Created by sacry on 20/05/15.
 */
public abstract class ClassTwoImplBase {
    public abstract int methodOne(double param1) throws SomeException110;

    public abstract double methodTwo() throws SomeException112;

    public static ClassTwoImplBase narrowCast(Object rawObjectRef) {
        return (ClassTwoImplBase) rawObjectRef;
    }
}
