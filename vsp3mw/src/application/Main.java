package application;

import mware_lib.NameService;
import mware_lib.ObjectBroker;
import nameservice.NameServiceMain;

import java.io.IOException;

/**
 * Created by Swaneet on 27.05.2015.
 */
public class Main {
    public static void main(String[] args) throws IOException {
        ObjectBroker objBroker =
                ObjectBroker.init(
                        NameServiceMain.HOST,
                        NameServiceMain.PORT,
                        true);

        NameService ns = objBroker.getNameService();

        ns.rebind(5,"f�nf");
        System.out.println("Received: " + ns.resolve("f�nf"));
    }
}
