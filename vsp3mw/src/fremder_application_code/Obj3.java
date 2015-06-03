package fremder_application_code;

import accessor_two.ClassOneImplBase;
import accessor_two.SomeException112;
import accessor_two.SomeException304;

public class Obj3 extends ClassOneImplBase{

	public double methodOne(String param1, double param2) throws SomeException112 {
		
		Double d = Double.valueOf(param1);
		
		if(d > 5.0) {
			throw new SomeException112("accessor_two.SomeException112 with message: The value should not be larger than 5.0");
		}
		
		return param2 + d;
	}
	
	public double methodTwo (String param1, double param2) throws SomeException112, SomeException304 {
		
		Double d = Double.valueOf(param1);
		
		if(d == null) {
			throw new SomeException112("accessor_two.SomeException112 with message: The value should not be larger than 5.0");
		}
		
		if(param2 > 10.0) {
			throw new SomeException304("accessor_two.SomeException304 with message: The double value is not allowed to be larger than 10.0");
		}
		
		return d + param2 + d;
	}
}
