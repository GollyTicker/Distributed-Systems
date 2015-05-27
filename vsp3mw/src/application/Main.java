package application;

import com.google.gson.FieldNamingPolicy;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by Swaneet on 27.05.2015.
 */
public class Main {
    public static void main(String[] args) {
        Gson gson = new GsonBuilder()
                .disableHtmlEscaping()
                .setFieldNamingPolicy(FieldNamingPolicy.UPPER_CAMEL_CASE)
                .setPrettyPrinting()
                .serializeNulls()
                .create();
        HashMap<String, String> m = new HashMap<>();
        m.put("a", null);
        String js = gson.toJson(m);
        System.out.println(js);

        Map<String,String> m2 = gson.fromJson(gson.toJson(m), Map.class);
        System.out.println(m2);
        System.out.println(m2.get("a") != null ? m2.get("a").getClass() : m2.get("a"));
    }
}
