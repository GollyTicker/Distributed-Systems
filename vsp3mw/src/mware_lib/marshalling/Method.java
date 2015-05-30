package mware_lib.marshalling;

import java.util.Arrays;

/**
 * Created by sacry on 30/05/15.
 */
public class Method {

    public String methodName;
    public Object[] params;

    public Method(String methodName, Object[] params) {
        this.methodName = methodName;
        this.params = params;
    }

    public boolean isMethod(String methodName) {
        return methodName.equals(this.methodName);
    }

    @Override
    public String toString() {
        return "Method{" +
                "methodName='" + methodName + '\'' +
                ", params=" + Arrays.toString(params) +
                '}';
    }
}
