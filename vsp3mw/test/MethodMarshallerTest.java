import mware_lib.marshalling.MethodMarshaller;
import mware_lib.model.Method;
import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.assertEquals;

/**
 * Created by sacry on 27/05/15.
 */
public class MethodMarshallerTest {

    private Method myMethod;
    private String myJson;
    private Method unmarshalledMethod;

    @Before
    public void setUp() throws Exception {
        myMethod = new Method("reference", "doubleBy", new Object[]{2, 3});
        myJson = MethodMarshaller.marshall(myMethod);
        unmarshalledMethod = MethodMarshaller.unmarshall(myJson, Method.class);
    }

    @Test
    public void testMarshall() throws Exception {
        assertEquals(myJson, "{\"ObjectReference\":\"reference\",\"MethodName\":\"doubleBy\",\"MethodParameter\":[2,3],\"MessageType\":\"Method\"}");
    }

    @Test
    public void testUnmarshall() throws Exception {
        assertEquals(unmarshalledMethod, myMethod);
    }
}
