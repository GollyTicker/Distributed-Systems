package nameservice;

import mware_lib.NameService;

import java.io.IOException;
import java.net.UnknownHostException;
import java.util.HashMap;
import java.util.Map;
import mware_lib.tcp.*;

/**
 * Created by sacry on 20/05/15.
 */
public class NameServiceImpl extends NameService{

    private int port;
    private Map<String, Object> register;

    // TODO: mit echten ports arbeiten.

    public static void main(String[] args) throws IOException {
        System.out.println("Started Nameservice.");
        NameService ns = new NameServiceImpl(Integer.parseInt(args[0]));

        String bla = "my object";
        ns.rebind(bla, "hallo");

        Object result = ns.resolve("hallo");
        System.out.println("Result: " +result);

    }

    public NameServiceImpl(int port) throws IOException {
        this.port = port;
        register = new HashMap();
    }

    @Override
    public void rebind(Object servant, String name) {
        register.put(name, servant);
    }

    @Override
    public Object resolve(String name) {    // null als R�ckgabewert ist erlaubt
        return register.get(name);
    }

}
