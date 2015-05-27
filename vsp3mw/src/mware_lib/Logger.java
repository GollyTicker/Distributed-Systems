package mware_lib;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

public class Logger {

    public static boolean debug = false;

    public static void log(Class<?> source, Object message) {
        if (debug) {
            logHelper(source, message);
        }
    }

    public static void log(Class<?> source, Object message, boolean _debug) {
        if (_debug) {
            logHelper(source, message);
        }
    }

    private static DateFormat dateFormatter = new SimpleDateFormat("HH:mm:ss");

    private static void logHelper(Class<?> source, Object message) {
        String date = dateFormatter.format(new Date());
        String className = source.getSimpleName();
        String sanitizedMessage = message != null ? message.toString() : null;
        String logInfo = date + " <" + className + "> : " + sanitizedMessage;
        System.out.println(logInfo);
    }
}