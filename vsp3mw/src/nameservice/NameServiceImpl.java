package nameservice;

import mware_lib.Logger;
import mware_lib.NameService;

import java.io.IOException;
import java.net.UnknownHostException;
import java.util.HashMap;
import java.util.Map;
import mware_lib.tcp.*;

import static mware_lib.Logger.log;

/**
 * Created by sacry on 20/05/15.
 */
public class NameServiceImpl extends NameService {
    private Map<String, Object> register;

    public NameServiceImpl() throws IOException {
        register = new HashMap();
    }

    @Override
    public void rebind(Object servant, String name) {
        log(this, "NameService.rebind(" + servant + "," + name + ")");
        register.put(name, servant);
    }

    @Override
    public Object resolve(String name) {    // null als R�ckgabewert ist erlaubt
        log(this, "NameService.resolve("+ name + ")");
        return register.get(name);
    }

}
