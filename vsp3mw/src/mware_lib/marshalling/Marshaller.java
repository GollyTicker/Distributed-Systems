package mware_lib.marshalling;

import java.util.ArrayList;
import java.util.Arrays;

/**
 * Created by sacry on 30/05/15.
 */
public class Marshaller {

    public static String SEP = ";";

    public static ArrayList<String> split(String s){
        return new ArrayList(Arrays.asList(s.split(SEP)));
    }

}
