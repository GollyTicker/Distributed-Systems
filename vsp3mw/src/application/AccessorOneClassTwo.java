package application;

import accessor_one.ClassTwoImplBase;
import accessor_one.SomeException110;
import accessor_one.SomeException112;

/**
 * Created by Swaneet on 31.05.2015.
 */
public class AccessorOneClassTwo extends ClassTwoImplBase {
    @Override
    public int methodOne(double param1) throws SomeException110 {
        return 10;
    }

    @Override
    public double methodTwo() throws SomeException112 {
        return 42.0;
    }
}
