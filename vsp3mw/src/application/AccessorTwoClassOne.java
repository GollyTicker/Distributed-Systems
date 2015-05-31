package application;

import accessor_two.ClassOneImplBase;
import accessor_two.SomeException112;
import accessor_two.SomeException304;

/**
 * Created by Swaneet on 31.05.2015.
 */
public class AccessorTwoClassOne extends ClassOneImplBase {
    @Override
    public double methodOne(String param1, double param2) throws SomeException112 {
        return 0;
    }

    @Override
    public double methodTwo(String param1, double param2) throws SomeException112, SomeException304 {
        return 0;
    }
}
