package nameservice;

import mware_lib.NameService;

/**
 * Created by sacry on 20/05/15.
 */
public class NameServiceImpl extends NameService{

    private int port;

    public NameServiceImpl(int port){
        this.port = port;
    };

    @Override
    public void rebind(Object servant, String name) {

    }

    @Override
    public Object resolve(String name) {
        return null;
    }

}
