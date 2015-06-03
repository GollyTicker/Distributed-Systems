package fremder_application_code;

import java.util.Random;

import accessor_one.ClassTwoImplBase;
import accessor_one.SomeException110;
import accessor_one.SomeException112;

public class Obj2 extends ClassTwoImplBase{

	public int methodOne(double param1) throws SomeException110 {
		if (param1 == 0.0) {
			throw new SomeException110("accessor_one.SomeException110 with message: The double value can't be 0");
		}
		
		return (int) (100/param1);
	}
	
	public double methodTwo() throws SomeException112 {
		Random r = new Random();
		double res = r.nextDouble();
	
		if (res > 0.5) {
			throw new SomeException112("accessor_one.SomeException112 with message: The value should not be larger than 0.5");
		}	
		
		return res;
	}
	
}
