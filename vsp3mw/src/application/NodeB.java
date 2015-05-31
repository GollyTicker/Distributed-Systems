package application;

import accessor_two.ClassOneImplBase;
import accessor_two.SomeException112;
import mware_lib.NameService;
import mware_lib.ObjectBroker;
import nameservice.NameServiceMain;

import java.io.IOException;

/**
 * Created by Swaneet on 31.05.2015.
 */
public class NodeB {
    public static void main(String[] args) throws IOException {
        ObjectBroker objBroker =
                ObjectBroker.init(
                        NameServiceMain.HOST,
                        NameServiceMain.PORT,
                        true);

        NameService ns = objBroker.getNameService();
        Object rawObject = ns.resolve("mycls");

        ClassOneImplBase cls = ClassOneImplBase.narrowCast(rawObject);

        System.out.println("Resolved: " + cls);

        double res = 0;
        try {
            res = cls.methodOne("15",12);
        } catch (SomeException112 someException112) {
            someException112.printStackTrace();
        }
        System.out.println("Should be 27: " + res);
    }
}
