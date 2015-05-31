package accessor_two;

/**
 * Created by Swaneet on 31.05.2015.
 */
public class ClassOneProxy extends ClassOneImplBase {

    /*
        double methodOne(String param1, double param2) throws SomeException112

        double methodTwo(String param1, double param2) throws SomeException112, someException304
    */

    public static String METHODONE = "methodOne";
    public static String METHODTWO = "methodTwo";

    @Override
    public double methodOne(String param1, double param2) throws SomeException112 {
        return 0;
    }

    @Override
    public double methodTwo(String param1, double param2) throws SomeException112, SomeException304 {
        return 0;
    }
}
