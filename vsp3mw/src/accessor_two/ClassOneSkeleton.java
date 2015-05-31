package accessor_two;

import mware_lib.skeleton.SingleMethod;
import mware_lib.skeleton.Skeleton;
import mware_lib.marshalling.ErrorMarshaller;
import mware_lib.marshalling.ReturnMarshaller;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

import static accessor_two.ClassOneProxy.METHODONE;
import static accessor_two.ClassOneProxy.METHODTWO;

/**
 * Created by sacry on 30/05/15.
 */
public class ClassOneSkeleton extends Skeleton<ClassOneImplBase> {

    /*
        double methodOne(String param1, double param2) throws SomeException112

        double methodTwo(String param1, double param2) throws SomeException112, SomeException304
    */

    public ClassOneSkeleton(int port, ClassOneImplBase cls) throws IOException {
        super(port,cls);
    }

    // double methodOne(String param1, double param2) throws SomeException112
    private static SingleMethod<ClassOneImplBase> methodOne =
        (ClassOneImplBase obj, Object[] params) -> {
            String param1 = (String) params[0];
            double param2 = ((Double) params[1]).doubleValue();
            String response = "";
            try {
                double res = obj.methodOne(param1,param2);
                response = ReturnMarshaller.marshall(new Double(res));
            }
            catch (SomeException112 e){
                response = ErrorMarshaller.marshall(e);
            }
          return response;
        };

    // double methodTwo(String param1, double param2) throws SomeException112, SomeException304
    private static SingleMethod<ClassOneImplBase> methodTwo =
        (ClassOneImplBase obj,Object[] params) -> {
            String param1 = (String) params[0];
            double param2 = ((Double) params[1]).doubleValue();
            String response = "";
            try {
                double res = obj.methodTwo(param1,param2);
                response = ReturnMarshaller.marshall(new Double(res));
            }
            catch (SomeException112 e) {
                response = ErrorMarshaller.marshall(e);
            }
            catch (SomeException304 e) {
                response = ErrorMarshaller.marshall(e);
            }
            return response;
        };

    @Override
    public String[] methodsNames() {
        return new String[]{METHODONE,METHODTWO};
    }

    @Override
    public List<SingleMethod<ClassOneImplBase>> methods() {
        return Arrays.asList(methodOne,methodTwo);
    }
}
