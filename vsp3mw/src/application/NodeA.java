package application;

import accessor_two.ClassOneImplBase;
import mware_lib.NameService;
import mware_lib.ObjectBroker;
import nameservice.NameServiceMain;

import java.io.IOException;

/**
 * Created by Swaneet on 31.05.2015.
 */
public class NodeA {
    public static void main(String[] args) throws IOException {

        ObjectBroker objBroker =
                ObjectBroker.init(
                        NameServiceMain.HOST,
                        NameServiceMain.PORT,
                        true);

        NameService ns = objBroker.getNameService();

        ClassOneImplBase cls = new AccessorTwoClassOne();

        ns.rebind(cls,"mycls");
        System.out.println("Rebinded: " + cls);
    }
}
