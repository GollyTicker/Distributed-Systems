package mware_lib.marshalling;

import accessor_one.SomeException110;
import org.junit.Before;
import org.junit.Test;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.*;

/**
 * Created by sacry on 31/05/15.
 */
public class MethodMarshallerTest {

    Method methodWithParams;
    String methodWithParamsMarshalled = "method;methodWithParams;2;[appobject;java.lang.String;b#appobject;java.lang.Double;6.2]";

    Method methodWithException;
    String methodWithExceptionMarshalled = "method;methodWithException;2;[appobject;java.lang.Integer;1#appobject;accessor_one.SomeException110;accessor_one.SomeException110: abc]";

    Method methodWithoutParams;
    String methodWithoutParamsMarshalled = "method;methodWithoutParams;0;[]";

    ArrayList<Method> methods;

    @Before
    public void setUp() throws Exception {
        methodWithParams = new Method("methodWithParams", new Object[]{"b", new Double(6.2)});
        methodWithException = new Method("methodWithException", new Object[]{new Integer(1), new SomeException110("abc")});
        methodWithoutParams = new Method("methodWithoutParams", new Object[]{});
        methods = new ArrayList<>(
                Arrays.asList(
                        methodWithParams,
                        methodWithoutParams,
                        methodWithException
                )
        );
    }

    @Test
    public void testMarshall() throws Exception {
        assertEquals(methodWithParamsMarshalled, MethodMarshaller.marshall(methodWithParams));
        assertEquals(methodWithExceptionMarshalled, MethodMarshaller.marshall(methodWithException));
        assertEquals(methodWithoutParamsMarshalled, MethodMarshaller.marshall(methodWithoutParams));
    }

    @Test
    public void testDemarshall() throws Exception {
        assertEquals(methodWithParams, MethodMarshaller.demarshall(methodWithParamsMarshalled));
        assertEquals(methodWithException, MethodMarshaller.demarshall(methodWithExceptionMarshalled));
        assertEquals(methodWithoutParams, MethodMarshaller.demarshall(methodWithoutParamsMarshalled));
    }

    @Test
    public void testMain() throws Exception {
        for (Method method : methods) {
            String s = MethodMarshaller.marshall(method);
            Method m = MethodMarshaller.demarshall(s);
            assertEquals(method, m);
        }
    }
}