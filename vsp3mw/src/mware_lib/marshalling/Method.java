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

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Method method = (Method) o;
        if (methodName != null ? !methodName.equals(method.methodName) : method.methodName != null) return false;
        if (params.length != method.params.length) return false;

        for (int idx = 0; idx < params.length; idx++) {

            Object paramsObj = params[idx];
            Object otherParamsObj = method.params[idx];

            if (paramsObj == null && otherParamsObj != null)
                return false;
            if (paramsObj != null && otherParamsObj == null)
                return false;

            if (paramsObj.getClass().equals(otherParamsObj.getClass())) {
                if (paramsObj instanceof Exception) {
                    if (otherParamsObj instanceof Exception) {
                        String e1 = ((Exception) paramsObj).getMessage();
                        String e2 = ((Exception) otherParamsObj).getMessage();
                        if (!e1.equals(e2))
                            return false;
                    } else {
                        return false;
                    }
                } else if (!paramsObj.equals(otherParamsObj)) {
                    return false;
                }
            } else {
                return false;
            }
        }
        return true;
    }
}
