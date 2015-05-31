package mware_lib.marshalling;

import accessor_one.SomeException110;
import org.junit.Before;
import org.junit.Test;

import java.util.ArrayList;
import java.util.Arrays;

import static org.junit.Assert.*;

/**
 * Created by sacry on 31/05/15.
 */
public class ErrorMarshallerTest {

    SomeException110 exception110;
    String exception110Marshalled = "exception;appobject;accessor_one.SomeException110;accessor_one.SomeException110: Some Exception";

    ArrayIndexOutOfBoundsException arrayIndexOutOfBoundsException;
    String arrayIndexOutOfBoundsExceptionMarshalled = "exception;appobject;java.lang.ArrayIndexOutOfBoundsException;java.lang.ArrayIndexOutOfBoundsException: Index out of bound";

    IndexOutOfBoundsException noMessageException;
    String noMessageExceptionMarshalled = "exception;appobject;java.lang.IndexOutOfBoundsException;java.lang.IndexOutOfBoundsException";

    String noException;

    ArrayList<Object> commands;

    @Before
    public void setUp() throws Exception {
        exception110 = new SomeException110("Some Exception");
        arrayIndexOutOfBoundsException = new ArrayIndexOutOfBoundsException("Index out of bound");
        noMessageException = new IndexOutOfBoundsException();
        noException = "This is no exception";

        commands = new ArrayList<>(
                Arrays.asList(
                        exception110,
                        arrayIndexOutOfBoundsException,
                        noMessageException
                )
        );
    }

    @Test
    public void testMarshall() throws Exception {
        assertEquals(exception110Marshalled, ErrorMarshaller.marshall(exception110));
        assertEquals(arrayIndexOutOfBoundsExceptionMarshalled, ErrorMarshaller.marshall(arrayIndexOutOfBoundsException));
        assertEquals(noMessageExceptionMarshalled, ErrorMarshaller.marshall(noMessageException));
    }

    @Test
    public void testDemarshall() throws Exception {
        String exceptionMsg = ErrorMarshaller.demarshall(exception110Marshalled).getMessage();
        assertEquals(exception110.getMessage(), exceptionMsg);
        exceptionMsg = ErrorMarshaller.demarshall(arrayIndexOutOfBoundsExceptionMarshalled).getMessage();
        assertEquals(arrayIndexOutOfBoundsException.getMessage(), exceptionMsg);
        exceptionMsg = ErrorMarshaller.demarshall(noMessageExceptionMarshalled).getMessage();
        assertEquals(noMessageException.getMessage(), exceptionMsg);
    }

    @Test
    public void testIsException() throws Exception {
        boolean exception = ErrorMarshaller.isException(noException);
        assertFalse(exception);
        exception = ErrorMarshaller.isException(exception110Marshalled);
        assertTrue(exception);
        exception = ErrorMarshaller.isException(noMessageExceptionMarshalled);
        assertTrue(exception);
    }

    @Test
    public void testMain() throws Exception {
        for (Object command : commands) {
            String s = AppObjectMarshaller.marshall(command);
            Object o = AppObjectMarshaller.demarshall(s);
            String e1 = ((Exception) command).getMessage();
            String e2 = ((Exception) o).getMessage();
            assertEquals(e1, e2);
        }
    }
}