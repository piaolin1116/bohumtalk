package com.bohumtalk.app.util;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.Iterator;

public class Common {
    public static String convertNull(String targetTxt){
        return Common.convertNull(targetTxt, "");
    }
    public static String convertNull(String targetTxt, String convertTxt){
        if(targetTxt == null){
            targetTxt = convertTxt;
        }
        return targetTxt;
    }
    public static String getJsonTxt(Hashtable obj){
        JsonParsing parsing = new JsonParsing();
        parsing.setJsonObj(obj);
        parsing.parseToText();
        return parsing.getMakeText();
    }
    public static String getShortDateString() {
        java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat ("yyyyMMdd", java.util.Locale.KOREA);
        return formatter.format(new java.util.Date());
    }
    public static String getShortTimeString() {
        java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat ("HHmmss", java.util.Locale.KOREA);
        return formatter.format(new java.util.Date());
    }
    public static String convertJuminToYYYYMMDD(String jumin){
        if(jumin.length() <= 6){
            return null;
        }
        String sex_code = jumin.substring(6,7);
        if("/9/0/".indexOf("/"+sex_code+"/")!=-1) return null;
        return new StringBuffer().append("/1/2/5/6/".indexOf("/"+sex_code+"/")!=-1?"19":"20").append(jumin.substring(0,6)).toString();
    }
    public static int convertJuminToSex(String jumin){
        if(jumin.length() <= 6){
            return -1;
        }
        String sex_code = jumin.substring(6,7);
        if("/9/0/".indexOf("/"+sex_code+"/")!=-1) return -1;
        return 2-Integer.parseInt(sex_code)%2;
    }

    public static String getValue(Hashtable rtnTable, String key){
        if(rtnTable == null) return "";
        if(rtnTable.get(key) == null) return "";
        Object obj_value = rtnTable.get(key);
        String rtnValue = "";
        if(obj_value != null){
            rtnValue = (String)obj_value;
        }
        return rtnValue;
    }

    public static void debug(Hashtable debugTable, ArrayList debugList){
        if(debugTable != null){
            Iterator it = debugTable.keySet().iterator();
            while(it.hasNext()){
                String key = (String)it.next();
                Object value = debugTable.get(key);
                String str_value = "";
                if(value instanceof String){
                    str_value = (String)value;
                    System.out.println(key + " : " + str_value);
                }else if(value instanceof Hashtable){
                    System.out.println("----------HASH-"+key+" start----------");
                    debug((Hashtable)value,null);
                    System.out.println("----------HASH-"+key+" end----------");
                }else if(value instanceof ArrayList){
                    System.out.println("----------ARRAY-"+key+" start----------");
                    debug(null, (ArrayList)value);
                    System.out.println("----------ARRAY-"+key+" end----------");
                }
            }
        }else if(debugList != null){
            for(int i=0;i<debugList.size();i++){
                Object obj = debugList.get(i);
                if(obj instanceof String){
                    System.out.println((String)obj);
                }else if(obj instanceof Hashtable){
                    System.out.println("----------HASH-"+i+" START----------");
                    debug((Hashtable)obj, null);
                    System.out.println("----------HASH-"+i+" END----------");
                }else if(obj instanceof ArrayList){
                    System.out.println("----------ARRAY-"+i+" START----------");
                    debug(null, (ArrayList)obj);
                    System.out.println("----------ARRAY-"+i+" END----------");
                }
            }
        }
    }
    
}
