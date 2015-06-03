package accessor_one;

import mware_lib.marshalling.ErrorMarshaller;
import mware_lib.marshalling.ReturnMarshaller;
import mware_lib.skeleton.SingleMethod;
import mware_lib.skeleton.Skeleton;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

import static accessor_one.ClassOneProxy.METHODONE;

/**
 * Created by sacry on 31/05/15.
 */
public class ClassOneSkeleton extends Skeleton<ClassOneImplBase> {


    /*
        String methodOne(String param1, int param2) throws SomeException112
    */

    public ClassOneSkeleton(int port, ClassOneImplBase cls) throws IOException {
        super(port, cls);
    }

    // String methodOne(String param1, int param2) throws SomeException112
    private static SingleMethod<ClassOneImplBase> methodOne =
            (ClassOneImplBase obj, Object[] params) -> {
                String param1 = (String) params[0];
                Integer param2 = Integer.parseInt(String.valueOf(params[1]));
                String response = "";
                try {
                    String res = obj.methodOne(param1, param2);
                    response = ReturnMarshaller.marshall(res);
                } catch (SomeException112 e) {
                    response = ErrorMarshaller.marshall(e);
                }
                return response;
            };

    @Override
    public String[] methodsNames() {
        return new String[]{METHODONE};
    }

    @Override
    public List<SingleMethod<ClassOneImplBase>> methods() {
        return Arrays.asList(methodOne);
    }
}
