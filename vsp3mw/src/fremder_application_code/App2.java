package fremder_application_code;

import mware_lib.NameService;
import mware_lib.ObjectBroker;
import accessor_one.ClassOneImplBase;
import accessor_one.SomeException110;
import accessor_one.SomeException112;
import nameservice.NameServiceMain;

import java.io.IOException;

public class App2 {
	
	private static final String OBJ_Name3 = "obj3";

	public static void main(String[] args) throws SomeException112, SomeException110, accessor_two.SomeException112, IOException {
//		Obj3 o = new Obj3();
		ObjectBroker ob = ObjectBroker.init(NameServiceMain.HOST, NameServiceMain.PORT, true);
		NameService ns = ob.getNameService();
//		ns.rebind(o, OBJ_Name3);
		
		Object raw = ns.resolve("obj1");
		ClassOneImplBase remoteObj = ClassOneImplBase.narrowCast(raw);
		System.out.println(remoteObj.methodOne("test", 5));
		
		Object raw2 = ns.resolve("obj3");
		accessor_two.ClassOneImplBase remoteObj2 = accessor_two.ClassOneImplBase.narrowCast(raw2);
		System.out.println(remoteObj2.methodOne("15.0", 6.0));
	}
}
