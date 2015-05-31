package mware_lib.marshalling;

import org.junit.Before;
import org.junit.Test;

import java.lang.reflect.Constructor;
import java.lang.reflect.Type;

import static org.junit.Assert.*;

/**
 * Created by sacry on 31/05/15.
 */
public class TypeMappingTest {

    String someString;
    String someStringType = "java.lang.String";

    Integer someInt;
    String someIntType = "java.lang.Integer";

    Void voidObj;
    String voidObjType = "java.lang.Void";

    Object nullObj;
    String nullObjType = "mware_lib.marshalling.TypeMapping$Null";

    @Before
    public void setUp() throws Exception {
        someString = "myStr";
        someInt = new Integer(5);
        Constructor<Void> constructor = Void.class.getDeclaredConstructor();
        constructor.setAccessible(true);
        voidObj = constructor.newInstance();
        nullObj = null;
    }

    @Test
    public void printNameTest() {
        System.out.println("TypingObjectTest");
    }

    @Test
    public void testGetType() throws Exception {
        assertEquals(someString.getClass(), TypeMapping.getType(someStringType));
        assertEquals(someInt.getClass(), TypeMapping.getType(someIntType));
        assertEquals(voidObj.getClass(), TypeMapping.getType(voidObjType));
        assertEquals(TypeMapping.Null.class, TypeMapping.getType(nullObjType));
    }

    @Test
    public void testGetTypeName() throws Exception {
        assertEquals(someStringType, TypeMapping.getTypeName(someString));
        assertEquals(someIntType, TypeMapping.getTypeName(someInt));
        assertEquals(voidObjType, TypeMapping.getTypeName(voidObj));
        assertEquals(nullObjType, TypeMapping.getTypeName(nullObj));
    }

    @Test
    public void testFromString() throws Exception {
        assertEquals("myStr", TypeMapping.fromString(someString, String.class));
        assertEquals(5, TypeMapping.fromString(someInt.toString(), Integer.class));
        assertEquals("void", TypeMapping.fromString(voidObj.toString(), Void.class));
        assertTrue(TypeMapping.fromString(null, TypeMapping.Null.class) == null);
    }
}