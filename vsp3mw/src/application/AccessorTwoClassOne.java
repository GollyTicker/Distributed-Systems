package application;

import accessor_two.ClassOneImplBase;
import accessor_two.SomeException112;
import accessor_two.SomeException304;

/**
 * Created by Swaneet on 31.05.2015.
 */
public class AccessorTwoClassOne extends ClassOneImplBase {

    // Thread tests?

    @Override
    public double methodOne(String param1, double param2) throws SomeException112 {
        System.out.println("method one string: " + param1);

        try {
            double d = Double.parseDouble(param1);
            return d + param2;
        } catch (Exception e) {
            throw new SomeException112(e.getMessage());
        }
    }

    @Override
    public double methodTwo(String param1, double param2) throws SomeException112, SomeException304 {
        System.out.println("method two string: " + param1);
        return Double.parseDouble(param1) - param2;
    }
}
