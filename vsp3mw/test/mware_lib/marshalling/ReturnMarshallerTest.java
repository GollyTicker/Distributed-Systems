package mware_lib.marshalling;

import org.junit.Before;
import org.junit.Test;

import java.util.ArrayList;
import java.util.Arrays;

import static org.junit.Assert.*;

/**
 * Created by sacry on 31/05/15.
 */
public class ReturnMarshallerTest {

    String someString;
    String someStringMarshalled = "return;appobject;java.lang.String;myStr";

    String emptyString;
    String emptyStringMarshalled = "return;appobject;java.lang.String;";

    Integer someInt;
    String someIntMarshalled = "return;appobject;java.lang.Integer;5";

    String noReturnObjectMarshalled = "appobject;java.lang.String;myStr";

    ArrayList<Object> commands;

    @Before
    public void setUp() throws Exception {
        someString = "myStr";
        emptyString = "";
        someInt = new Integer(5);
        commands = new ArrayList<>(
                Arrays.asList(
                        someString,
                        emptyString,
                        someInt
                )
        );
    }

    @Test
    public void testMarshall() throws Exception {
        assertEquals(someStringMarshalled, ReturnMarshaller.marshall(someString));
        assertEquals(emptyStringMarshalled, ReturnMarshaller.marshall(emptyString));
        assertEquals(someIntMarshalled, ReturnMarshaller.marshall(someInt));
    }

    @Test
    public void testDemarshall() throws Exception {
        assertEquals(someString, ReturnMarshaller.demarshall(someStringMarshalled));
        assertEquals(emptyString, ReturnMarshaller.demarshall(emptyStringMarshalled));
        assertEquals(someInt, ReturnMarshaller.demarshall(someIntMarshalled));
    }

    @Test
    public void testIsReturn() throws Exception {
        boolean isReturn = ReturnMarshaller.isReturn(noReturnObjectMarshalled);
        assertFalse(isReturn);
        isReturn = ReturnMarshaller.isReturn(emptyStringMarshalled);
        assertTrue(isReturn);
    }

    @Test
    public void testMain() throws Exception {
        for (Object command : commands) {
            String s = ReturnMarshaller.marshall(command);
            Object o = ReturnMarshaller.demarshall(s);
            assertEquals(command, o);
        }
    }
}