package mware_lib;

/**
 * Created by sacry on 20/05/15.
 */
public abstract class NameService {

    public abstract void rebind(Object servant, String name);

    public abstract Object resolve(String name);
}
