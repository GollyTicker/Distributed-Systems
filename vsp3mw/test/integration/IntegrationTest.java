package integration;

import accessor_one.SomeException110;
import accessor_two.SomeException304;
import mware_lib.NameService;
import mware_lib.ObjectBroker;
import nameservice.NameServiceMain;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;

import static org.junit.Assert.*;

/**
 * Created by sacry on 31/05/15.
 */
public class IntegrationTest {

    static Thread nameServiceMain;
    static ObjectBroker nodeA;
    static ObjectBroker nodeB;

    static accessor_two.ClassOneImplBase a2c1Real;
    static accessor_one.ClassOneImplBase a1c1Real;
    static accessor_one.ClassTwoImplBase a1c2Real;
    static accessor_two.ClassOneImplBase a2c1Proxy;
    static accessor_one.ClassOneImplBase a1c1Proxy;
    static accessor_one.ClassTwoImplBase a1c2Proxy;

    @BeforeClass
    public static void setUp() throws Exception {
        nameServiceMain = new Thread(new NameServiceMain());
        nameServiceMain.start();
        Thread.sleep(200L);
        nodeA = ObjectBroker.init(
                NameServiceMain.HOST,
                NameServiceMain.PORT,
                true
        );
        Thread.sleep(200L);
        nodeB = ObjectBroker.init(
                NameServiceMain.HOST,
                NameServiceMain.PORT,
                true
        );
    }

    @AfterClass
    public static void tearDown(){
        nameServiceMain.interrupt();
        nodeA.shutDown();
        nodeB.shutDown();
    }

    @Test
    public void testMain() throws Exception {
        rebindNode(nodeA);
        resolveNode(nodeB);

        // Accessor Two Class One
        double result = 0;
        double resultResolved = 0;
        result = a2c1Real.methodOne("15", 12);
        resultResolved = a2c1Proxy.methodOne("15", 12);

        assertTrue(new Double(27).equals(result));
        assertTrue(new Double(27).equals(resultResolved));
        assertTrue(new Double(result).equals(resultResolved));

        result = a2c1Real.methodTwo("15", 12);
        resultResolved = a2c1Proxy.methodTwo("15", 12);

        assertTrue(new Double(3).equals(result));
        assertTrue(new Double(3).equals(resultResolved));
        assertTrue(new Double(result).equals(resultResolved));

        // Accessor One Class One
        String strReal = a1c1Real.methodOne("15",12);
        String strProxy = a1c1Proxy.methodOne("15",12);
        assertTrue(strReal.equals(strProxy));
        assertTrue(strProxy.equals("3"));

        // Accessor One Class Two
        int intReal = a1c2Real.methodOne(12.0);
        int intProxy = a1c2Proxy.methodOne(12.0);
        assertTrue(intReal == intProxy);
        assertTrue(intReal == 10);

        double doubleReal = a1c2Real.methodTwo();
        double doubleProxy = a1c2Proxy.methodTwo();
        assertTrue(doubleReal == doubleProxy);
        assertTrue(doubleProxy == 42.0);

    }

    @Test(expected = accessor_one.SomeException112.class)
    public void testExceptionA1C1() throws accessor_one.SomeException112 {
        rebindNode(nodeA);
        resolveNode(nodeB);
        a1c1Proxy.methodOne("invalid integer", 15);
        System.out.println("HALLLLLLLO");
    }

    @Test(expected = accessor_two.SomeException112.class)
    public void testExceptionsA2C1() throws accessor_two.SomeException112 {
        rebindNode(nodeA);
        resolveNode(nodeB);
        a2c1Proxy.methodOne("invalid double", 15);
    }

    private void rebindNode(ObjectBroker node) {
        NameService ns = node.getNameService();
        a2c1Real = new AccessorTwoClassOne();
        ns.rebind(a2c1Real, "cls1");
        a1c1Real = new AccessorOneClassOne();
        ns.rebind(a1c1Real, "cls2");
        a1c2Real = new AccessorOneClassTwo();
        ns.rebind(a1c2Real, "cls3");
    }

    private void resolveNode(ObjectBroker node) {
        NameService ns = node.getNameService();
        Object rawObject1 = ns.resolve("cls1");
        a2c1Proxy = accessor_two.ClassOneImplBase.narrowCast(rawObject1);
        Object rawObject2 = ns.resolve("cls2");
        a1c1Proxy = accessor_one.ClassOneImplBase.narrowCast(rawObject2);
        Object rawObject3 = ns.resolve("cls3");
        a1c2Proxy = accessor_one.ClassTwoImplBase.narrowCast(rawObject3);
        return;
    }

    // Implementationen des Anwendungscodes für unsere Testsfälle

    private class AccessorOneClassOne extends accessor_one.ClassOneImplBase {
        @Override
        public String methodOne(String param1, int param2) throws accessor_one.SomeException112 {
            try {
                return String.valueOf(Integer.parseInt(param1) - param2);
            } catch (Exception e){
                throw new accessor_one.SomeException112(e.getMessage());
            }
        }
    }

    private class AccessorOneClassTwo extends accessor_one.ClassTwoImplBase {
        @Override
        public int methodOne(double param1) throws SomeException110 {
            return 10;
        }

        @Override
        public double methodTwo() throws accessor_one.SomeException112 {
            return 42.0;
        }
    }

    private class AccessorTwoClassOne extends accessor_two.ClassOneImplBase {
        @Override
        public double methodOne(String param1, double param2) throws accessor_two.SomeException112 {
            System.out.println("method one string: " + param1);

            try {
                double d = Double.parseDouble(param1);
                return d + param2;
            } catch (Exception e) {
                throw new accessor_two.SomeException112(e.getMessage());
            }
        }

        @Override
        public double methodTwo(String param1, double param2) throws accessor_two.SomeException112, SomeException304 {
            System.out.println("method two string: " + param1);
            return Double.parseDouble(param1) - param2;
        }
    }
}
