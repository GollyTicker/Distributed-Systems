package mware_lib.skeleton;

public interface SingleMethod<A> {
    String call(A obj, Object[] params) throws Exception;
}
