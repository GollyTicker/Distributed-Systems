package mware_lib;

import accessor_one.SomeException110;
import nameservice.NameServiceImpl;
import nameservice.NameServiceSkeleton;
import org.junit.Before;
import org.junit.Test;

import java.util.Arrays;
import java.util.List;

import static org.junit.Assert.*;

/**
 * Created by Swaneet on 31.05.2015.
 */
public class NameServiceTest {

    NameService nsProxy;
    NameService nsReal;
    NameServiceSkeleton nsSkel;
    final static String LOCALHOST = "localhost";
    static int nssPort = 50001;

    @Before
    public void runBeforeEachTest() throws Exception {
        // Auf dem NameService Node
        nsReal = new NameServiceImpl();
        nsSkel = new NameServiceSkeleton(nssPort,nsReal);

        // Auf client-side
        nsProxy = new NameServiceProxy(LOCALHOST,nssPort);
    }

    // Timeouts?

    @Test
    public void testMethods() throws Exception {
        nsProxy.rebind(1400,"five");
        assertEquals(1400,nsReal.resolve("five"));
        assertEquals(1400,nsProxy.resolve("five"));

        nsProxy.rebind(null,"null");
        assertEquals(null,nsReal.resolve("null"));
        assertEquals(null,nsProxy.resolve("null"));

        nsProxy.rebind(new Integer(1401),"six");
        assertEquals(new Integer(1401),nsReal.resolve("six"));
        assertEquals(new Integer(1401),nsProxy.resolve("six"));

        nsProxy.rebind(1402,"five");
        assertEquals(1402,nsReal.resolve("five"));
        assertEquals(1402,nsProxy.resolve("five"));

        nsProxy.rebind("bla","bla");
        assertEquals("bla",nsReal.resolve("bla"));
        assertEquals("bla",nsProxy.resolve("bla"));

        nsProxy.rebind(4.1,"bla");
        assertEquals(4.1,nsReal.resolve("bla"));
        assertEquals(4.1,nsProxy.resolve("bla"));

        nsProxy.rebind(new SomeException110("15"),"ex");
        assertEquals(new SomeException110("15").getMessage(), ((SomeException110) nsReal.resolve("ex")).getMessage());
        assertEquals(new SomeException110("15").getMessage(),((SomeException110)nsProxy.resolve("ex")).getMessage());

        assertEquals(null,nsReal.resolve("unknown"));
        assertEquals(null,nsProxy.resolve("unknown"));
    }
}