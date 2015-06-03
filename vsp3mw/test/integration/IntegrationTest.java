package integration;

import accessor_two.ClassOneImplBase;
import accessor_two.SomeException112;
import application.AccessorTwoClassOne;
import mware_lib.NameService;
import mware_lib.ObjectBroker;
import nameservice.NameServiceMain;
import org.junit.BeforeClass;
import org.junit.Test;

import static org.junit.Assert.*;

/**
 * Created by sacry on 31/05/15.
 */
public class IntegrationTest {

    static ObjectBroker nodeA;
    static ObjectBroker nodeB;

    @BeforeClass
    public static void setUp() throws Exception {
        new Thread(new NameServiceMain()).start();
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

    @Test
    public void testMain() throws Exception {
        ClassOneImplBase cls1 = rebindNode(nodeA, "mycls");
        ClassOneImplBase cls2 = resolveNode(nodeB, "mycls");

        double result = 0;
        double resultResolved = 0;
        try {
            result = cls1.methodOne("15", 12);
            resultResolved = cls2.methodOne("15", 12);
        } catch (SomeException112 someException112) {
            someException112.printStackTrace();
        }

        assertTrue(new Double(27).equals(result));
        assertTrue(new Double(27).equals(resultResolved));
        assertTrue(new Double(result).equals(resultResolved));

        result = cls1.methodTwo("15", 12);
        resultResolved = cls2.methodTwo("15", 12);

        assertTrue(new Double(3).equals(result));
        assertTrue(new Double(3).equals(resultResolved));
        assertTrue(new Double(result).equals(resultResolved));
    }

    @Test(expected = SomeException112.class)
    public void testExceptions() throws SomeException112{
        ClassOneImplBase cls1 = rebindNode(nodeA, "mycls");
        ClassOneImplBase cls2 = resolveNode(nodeB, "mycls");

        cls2.methodOne("wrong",15);
    }

    private ClassOneImplBase rebindNode(ObjectBroker node, String className) {
        NameService ns = node.getNameService();
        ClassOneImplBase cls = new AccessorTwoClassOne();
        ns.rebind(cls, className);
        return cls;
    }

    private ClassOneImplBase resolveNode(ObjectBroker node, String className) {
        NameService ns = node.getNameService();
        Object rawObject = ns.resolve(className);
        ClassOneImplBase clsResolved = ClassOneImplBase.narrowCast(rawObject);
        return clsResolved;
    }
}
