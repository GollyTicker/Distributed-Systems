package mware_lib.marshalling;

import java.util.Arrays;

/**
 * Created by sacry on 27/05/15.
 */
public class Method extends AbstractModel{

    public static Method init(String objectReference, String methodName, Object[] methodParameter){
        return new Method(objectReference, methodName, methodParameter);
    }

    private String objectReference;
    private String methodName;
    private Object[] methodParameter;

    public Method(String objectReference, String methodName, Object[] methodParameter) {
        this.objectReference = objectReference;
        this.methodName = methodName;
        this.methodParameter = methodParameter;
        this.messageType = "Method";
    }

    public void setObjectReference(String objectReference) {
        this.objectReference = objectReference;
    }

    public void setMethodName(String methodName) {
        this.methodName = methodName;
    }

    public void setMethodParameter(Object[] methodParameter) {
        this.methodParameter = methodParameter;
    }

    public String getObjectReference() {

        return objectReference;
    }

    public String getMethodName() {
        return methodName;
    }

    public Object[] getMethodParameter() {
        return methodParameter;
    }

    @Override
    public int hashCode() {
        return super.hashCode();
    }

    @Override
    public boolean equals(Object obj) {
        return super.equals(obj);
    }

    @Override
    public String toString() {
        return this.messageType + "{" +
                "objectReference='" + objectReference + '\'' +
                ", methodName='" + methodName + '\'' +
                ", methodParameter=" + Arrays.toString(methodParameter) +
                '}';
    }
}
