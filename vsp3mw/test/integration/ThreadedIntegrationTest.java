package integration;

import accessor_two.ClassOneImplBase;
import accessor_two.SomeException112;
import accessor_two.SomeException304;
import application.AccessorTwoClassOne;
import mware_lib.NameService;
import mware_lib.ObjectBroker;
import nameservice.NameServiceMain;
import org.junit.BeforeClass;
import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

/**
 * Created by sacry on 31/05/15.
 */
public class ThreadedIntegrationTest {

    static ObjectBroker nodeA;
    static ObjectBroker nodeB;

    @BeforeClass
    public static void setUp() throws Exception {
        new Thread(new NameServiceMain()).start();
        nodeA = ObjectBroker.init(
                NameServiceMain.HOST,
                NameServiceMain.PORT,
                true
        );
        nodeB = ObjectBroker.init(
                NameServiceMain.HOST,
                NameServiceMain.PORT,
                true
        );
    }

    private double OFFSET = 15;
    @Test
    public void testMain() throws Exception {
        rebindNode(nodeA, "mycls");
        ClassOneImplBase cls2 = resolveNode(nodeB, "mycls");

        Runnable r1 = () -> {
            try {
                double result = cls2.methodOne("", 10);
                assertTrue(result == (3 + OFFSET));
            }
            catch (Exception e){}
        };


        Thread t = new Thread(r1);
        t.start();
        Thread.sleep(300L);
        double ret2 = cls2.methodTwo("", 3);

        assertTrue(ret2 == 3);

        t.join();
    }

    private ClassOneImplBase rebindNode(ObjectBroker node, String className) {
        NameService ns = node.getNameService();
        ClassOneImplBase cls = new ThreadedAccessorTwoClassOne();
        ns.rebind(cls, className);
        return cls;
    }

    private ClassOneImplBase resolveNode(ObjectBroker node, String className) {
        NameService ns = node.getNameService();
        Object rawObject = ns.resolve(className);
        ClassOneImplBase clsResolved = ClassOneImplBase.narrowCast(rawObject);
        return clsResolved;
    }

    private class ThreadedAccessorTwoClassOne extends ClassOneImplBase {
        private double bla = 0;

        @Override
        public double methodOne(String param1, double param2) throws SomeException112 {
            bla = param2;
            System.out.println(" #### METHOD ONE before sleep: bla = " + bla);
            try {
                Thread.sleep(1200L);
            } catch (InterruptedException e) {}
            bla = bla + OFFSET;
            System.out.println(" #### METHOD ONE after sleep: bla = " + bla);
            return bla;
        }

        @Override
        public double methodTwo(String param1, double param2) throws SomeException112, SomeException304 {
            bla = param2;
            System.out.println(" #### METHOD TWO: bla = " + bla);
            return bla;
        }
    }
}
