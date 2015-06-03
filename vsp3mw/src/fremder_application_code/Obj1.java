package fremder_application_code;

import accessor_one.ClassOneImplBase;
import accessor_one.SomeException112;

public class Obj1 extends ClassOneImplBase{

	@Override
	public String methodOne(String param1, int param2) throws SomeException112 {
		
		if (param2 > 5) {
			throw new SomeException112("accessor_one.SomeException112 with message: The value should not be larger than 5");
		}
		
		return param1 + param2;
	}
	
}
