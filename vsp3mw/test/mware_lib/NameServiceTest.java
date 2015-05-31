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
        /*nsProxy.rebind("bla","bla");
        assertEquals("bla",nsReal.resolve("bla"));
        assertEquals("bla",nsProxy.resolve("bla"));

        assertEquals(null,nsReal.resolve("unknown"));
        assertEquals(null,nsProxy.resolve("unknown"));

        nsProxy.rebind("","");
        assertEquals("",nsReal.resolve(""));
        assertEquals("",nsProxy.resolve(""));*/
    }
}