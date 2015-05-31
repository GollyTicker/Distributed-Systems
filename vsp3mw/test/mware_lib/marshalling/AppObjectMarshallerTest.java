package mware_lib.marshalling;

import accessor_one.SomeException110;
import org.junit.Before;
import org.junit.Test;

import java.util.ArrayList;
import java.util.Arrays;

import mware_lib.marshalling.AppObjectMarshaller.*;

import static org.junit.Assert.*;

/**
 * Created by sacry on 31/05/15.
 */
public class AppObjectMarshallerTest {

    String someString;
    String someStringMarshalled = "appobject;java.lang.String;myStr";

    String emptyString;
    String emptyStringMarshalled = "appobject;java.lang.String;";

    Integer someInt;
    String someIntMarshalled = "appobject;java.lang.Integer;5";

    Double someDouble;
    String someDoubleMarshalled = "appobject;java.lang.Double;5.0";

    Object nullObj;
    String nullsMarshalled = "appobject;mware_lib.marshalling.TypeMapping$Null;null";

    SomeException110 exception110;
    String exception110Marshalled = "appobject;accessor_one.SomeException110;accessor_one.SomeException110: Some Exception";

    ArrayIndexOutOfBoundsException arrayIndexOutOfBoundsException;
    String arrayIndexOutOfBoundsExceptionMarshalled = "appobject;java.lang.ArrayIndexOutOfBoundsException;java.lang.ArrayIndexOutOfBoundsException: Index out of bound";

    IndexOutOfBoundsException noMessageException;
    String noMessageExceptionMarshalled = "appobject;java.lang.IndexOutOfBoundsException;java.lang.IndexOutOfBoundsException";

    ArrayList<Object> commands;


    @Before
    public void setUp() throws Exception {
        someString = "myStr";
        emptyString = "";
        someInt = new Integer(5);
        someDouble = new Double(5);
        nullObj = null;
        exception110 = new SomeException110("Some Exception");
        arrayIndexOutOfBoundsException = new ArrayIndexOutOfBoundsException("Index out of bound");
        noMessageException = new IndexOutOfBoundsException();
        commands = new ArrayList<>(
                Arrays.asList(
                        someString,
                        emptyString,
                        someInt,
                        someDouble,
                        nullObj,
                        exception110,
                        arrayIndexOutOfBoundsException,
                        noMessageException
                )
        );
    }

    @Test
    public void printNameTest()
    {
        System.out.println("AppObjectMarshallerTest");
    }

    @Test
    public void testMarshall() throws Exception {
        assertEquals(someStringMarshalled, AppObjectMarshaller.marshall(someString));
        assertEquals(emptyStringMarshalled, AppObjectMarshaller.marshall(emptyString));
        assertEquals(someIntMarshalled, AppObjectMarshaller.marshall(someInt));
        assertEquals(someDoubleMarshalled, AppObjectMarshaller.marshall(someDouble));
        assertEquals(nullsMarshalled, AppObjectMarshaller.marshall(nullObj));
        assertEquals(exception110Marshalled, AppObjectMarshaller.marshall(exception110));
        assertEquals(arrayIndexOutOfBoundsExceptionMarshalled, AppObjectMarshaller.marshall(arrayIndexOutOfBoundsException));
        assertEquals(noMessageExceptionMarshalled, AppObjectMarshaller.marshall(noMessageException));
    }

    @Test
    public void testDemarshall() throws Exception {
        assertEquals(someString, AppObjectMarshaller.demarshall(someStringMarshalled));
        assertEquals(emptyString, AppObjectMarshaller.demarshall(emptyStringMarshalled));
        assertEquals(someInt, AppObjectMarshaller.demarshall(someIntMarshalled));
        assertEquals(someDouble, AppObjectMarshaller.demarshall(someDoubleMarshalled));
        assertEquals(nullObj, AppObjectMarshaller.demarshall(nullsMarshalled));
        String exceptionMsg = ((Exception) AppObjectMarshaller.demarshall(exception110Marshalled)).getMessage();
        assertEquals(exception110.getMessage(), exceptionMsg);
        exceptionMsg = ((Exception) AppObjectMarshaller.demarshall(arrayIndexOutOfBoundsExceptionMarshalled)).getMessage();
        assertEquals(arrayIndexOutOfBoundsException.getMessage(), exceptionMsg);
        exceptionMsg = ((Exception) AppObjectMarshaller.demarshall(noMessageExceptionMarshalled)).getMessage();
        assertEquals(noMessageException.getMessage(), exceptionMsg);
    }

    @Test
    public void testMain() throws Exception {
        for (Object command : commands) {
            String s = AppObjectMarshaller.marshall(command);
            Object o = AppObjectMarshaller.demarshall(s);
            if (o instanceof Exception) {
                String e1 = ((Exception) command).getMessage();
                String e2 = ((Exception) o).getMessage();
                assertEquals(e1, e2);
            } else {
                assertEquals(command, o);
            }
        }
    }
}