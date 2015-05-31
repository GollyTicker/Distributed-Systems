package application;

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
        accessorTwoClassOne(ns);
        accessorOneClassOne(ns);
        accessorOneClassTwo(ns);
    }


    private static void accessorTwoClassOne(NameService ns) throws IOException {
        Object rawObject = ns.resolve("cls1");
        accessor_two.ClassOneImplBase cls1 = accessor_two.ClassOneImplBase.narrowCast(rawObject);

        System.out.println("Resolved: " + cls1);
        double res = 0;
        try {
            res = cls1.methodOne("15", 12);
        } catch (SomeException112 someException112) {
            someException112.printStackTrace();
        }
        System.out.println("Should be 27: " + res);
    }

    private static void accessorOneClassOne(NameService ns) throws IOException {
        Object rawObject = ns.resolve("cls2");
        accessor_one.ClassOneImplBase cls2 = accessor_one.ClassOneImplBase.narrowCast(rawObject);

        System.out.println("Resolved: " + cls2);
        String strResult = "";
        try {
            strResult = cls2.methodOne("15", 12);
        } catch (accessor_one.SomeException112 someException112) {
            someException112.printStackTrace();
        }
        System.out.println("Should be 3: " + strResult);
    }

    private static void accessorOneClassTwo(NameService ns) throws IOException {
        Object rawObject = ns.resolve("cls3");
        accessor_one.ClassTwoImplBase cls3 = accessor_one.ClassTwoImplBase.narrowCast(rawObject);

        System.out.println("Resolved: " + cls3);
        int res = 0;
        try {
            res = cls3.methodOne(12.0);
        } catch (accessor_one.SomeException110 someException110) {
            someException110.printStackTrace();
        }
        System.out.println("Should be 10: " + res);

        double res2 = 0;
        try {
            res2 = cls3.methodTwo();
        } catch (accessor_one.SomeException112 someException112) {
            someException112.printStackTrace();
        }
        System.out.println("Should be 42: " + res2);
    }
}
