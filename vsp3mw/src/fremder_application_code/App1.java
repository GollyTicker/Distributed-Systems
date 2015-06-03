package fremder_application_code;

import accessor_two.SomeException112;
import accessor_two.SomeException304;
import nameservice.NameServiceMain;
import mware_lib.*;

import java.io.IOException;

public class App1 {
	
	private static final String OBJ_Name1 = "obj1";
	private static final String OBJ_Name2 = "obj2";

	public static void main(String[] args) throws SomeException112, SomeException304, IOException {

		Obj1 o1 = new Obj1();
		Obj3 o3 = new Obj3();
		ObjectBroker ob = ObjectBroker.init(NameServiceMain.HOST, NameServiceMain.PORT, true);
		NameService ns = ob.getNameService();
		ns.rebind(o1, "obj1");
		ns.rebind(o3, "obj3");
		
//		Object raw = ns.resolve("obj3");
//		ClassOneImplBase remoteObj = ClassOneImplBase.narrowCast(raw);
//		System.out.println(remoteObj.methodOne("test", new Double(null)));
//		System.out.println(remoteObj.methodTwo("test", 5.0));
	}

}
