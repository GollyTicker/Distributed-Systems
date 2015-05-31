package accessor_one;

import mware_lib.marshalling.ErrorMarshaller;
import mware_lib.marshalling.ReturnMarshaller;
import mware_lib.skeleton.SingleMethod;
import mware_lib.skeleton.Skeleton;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

import static accessor_one.ClassTwoProxy.METHODONE;
import static accessor_one.ClassTwoProxy.METHODTWO;

/**
 * Created by sacry on 31/05/15.
 */
public class ClassTwoSkeleton extends Skeleton<ClassTwoImplBase> {

    public ClassTwoSkeleton(int port, ClassTwoImplBase cls) throws IOException {
        super(port, cls);
    }

    // int methodOne(double param1) throws SomeException110;
    private static SingleMethod<ClassTwoImplBase> methodOne =
            (ClassTwoImplBase obj, Object[] params) -> {
                double param1 = ((Double) params[0]).doubleValue();
                String response = "";
                try {
                    int res = obj.methodOne(param1);
                    response = ReturnMarshaller.marshall(new Integer(res));
                } catch (SomeException110 e) {
                    response = ErrorMarshaller.marshall(e);
                }
                return response;
            };

    // double methodTwo() throws SomeException112;
    private static SingleMethod<ClassTwoImplBase> methodTwo =
            (ClassTwoImplBase obj, Object[] params) -> {
                String response = "";
                try {
                    double res = obj.methodTwo();
                    response = ReturnMarshaller.marshall(new Double(res));
                } catch (SomeException112 e) {
                    response = ErrorMarshaller.marshall(e);
                }
                return response;
            };

    @Override
    public String[] methodsNames() {
        return new String[]{METHODONE, METHODTWO};
    }

    @Override
    public List<SingleMethod<ClassTwoImplBase>> methods() {
        return Arrays.asList(methodOne, methodTwo);
    }
}
