package application;

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
        accessor_two.ClassOneImplBase cls1 = new AccessorTwoClassOne();

        ns.rebind(cls1, "cls1");
        System.out.println("Rebinded: " + cls1);

        accessor_one.ClassOneImplBase cls2 = new AccessorOneClassOne();
        ns.rebind(cls2, "cls2");

        accessor_one.ClassTwoImplBase cls3 = new AccessorOneClassTwo();
        ns.rebind(cls3, "cls3");
    }
}
