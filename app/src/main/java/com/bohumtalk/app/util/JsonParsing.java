package com.bohumtalk.app.util;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.Iterator;

public class JsonParsing {
    Hashtable mainJsonData = new Hashtable();
    String mainJsonText = "";
    StringBuffer makeText = new StringBuffer();
    String errorText = "";
    final int MODE_NOT = 3;
    final int MODE_VALUE_CHK = 4;
    final int ACCESS_MODE_HASH = 5;
    final int ACCESS_MODE_ARRAY = 6;
    public JsonParsing(){
    }
    public JsonParsing(String jsonText){
        this.mainJsonText = jsonText;
        parsing();
    }
    public void setJsonText(String jsonText){
        this.mainJsonText = jsonText;
    }
    public void parsing(){
        parseJsonText(this.mainJsonData, this.mainJsonText, "main", null);
        this.mainJsonData = (Hashtable)this.mainJsonData.get("main");
    }
    public void setJsonObj(Hashtable jsonObj){
        this.mainJsonData = jsonObj;
    }
    public String getMakeText(){
        return this.makeText.toString();
    }
    public void parseToText(){
        parseJsonObjToText(this.mainJsonData);
    }
    public void parseJsonObjToText(Object callData){
        if(callData instanceof Hashtable){
            Hashtable parseData = (Hashtable)callData;
            Iterator it = parseData.keySet().iterator();
            int index = 0;
            this.makeText.append("{");
            while(it.hasNext()){
                String key = (String)it.next();
                Object value = parseData.get(key);
                if(index != 0){
                    this.makeText.append(", ");
                }
                this.makeText.append("\"");
                this.makeText.append(key);
                this.makeText.append("\": ");
                if(value instanceof Hashtable || value instanceof ArrayList){
                    parseJsonObjToText(value);
                }else{
                    this.makeText.append("\"");
                    this.makeText.append(value);
                    this.makeText.append("\"");
                }
                index++;
            }
            this.makeText.append("}");
        }else if(callData instanceof ArrayList){
            ArrayList parseData = (ArrayList)callData;
            this.makeText.append("[");
            for(int i=0;i<parseData.size();i++){
                Object value = parseData.get(i);
                if(i!=0){
                    this.makeText.append(", ");
                }
                if(value instanceof Hashtable || value instanceof ArrayList){
                    parseJsonObjToText(value);
                }else{
                    this.makeText.append("\"");
                    this.makeText.append(value);
                    this.makeText.append("\"");
                }
            }
            this.makeText.append("]");
        }
    }
    public void debug(Hashtable debugTable, ArrayList debugList){
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
                    System.out.println("==========HASH-"+key+"==========");
                    debug((Hashtable)value,null);
                    System.out.println("==========HASH-"+key+"==========");
                }else if(value instanceof ArrayList){
                    System.out.println("==========ARRAY-"+key+"==========");
                    debug(null, (ArrayList)value);
                    System.out.println("==========ARRAY-"+key+"==========");
                }
            }
        }else if(debugList != null){
            for(int i=0;i<debugList.size();i++){
                Object obj = debugList.get(i);
                if(obj instanceof String){
                    System.out.println((String)obj);
                }else if(obj instanceof Hashtable){
                    System.out.println("==========HASH-START==========");
                    debug((Hashtable)obj, null);
                    System.out.println("==========HASH-END==========");
                }else if(obj instanceof ArrayList){
                    System.out.println("==========ARRAY-START==========");
                    debug(null, (ArrayList)obj);
                    System.out.println("==========ARRAY-END==========");
                }
            }
        }
    }
    public int getMatchIndex(String strtxt, char startch, char endch){
        int index = 0;
        int match_index = 0;
        int current_mode = MODE_NOT;
        char before_ch = ' ';
        char start_ch = ' ';
        while(index < strtxt.length()){
            char ch = strtxt.charAt(index);
            if((ch == '"'||ch == '\'') && (start_ch == ch || start_ch == ' ') && before_ch != '\\'){
                if(current_mode == MODE_VALUE_CHK){
                    current_mode = MODE_NOT;
                    start_ch = ' ';
                }else{
                    current_mode = MODE_VALUE_CHK;
                    start_ch = ch;
                }
            }
            if(ch == startch && current_mode != MODE_VALUE_CHK){
                match_index++;
            }else if(ch == endch && current_mode != MODE_VALUE_CHK){
                match_index--;
            }
            if(match_index == 0 && ch == endch){
                break;
            }
            index++;
            before_ch = ch;
        }
        return index;
    }
    public Hashtable getMainData(){
        return this.mainJsonData;
    }
    public Object getData(String query){
        String rtnQuery = "";
        String excuteQuery = query;
        int index = 0;
        StringBuffer addData = new StringBuffer();
        Object currentObj = this.mainJsonData;
        while(index < excuteQuery.length()){
            char ch = excuteQuery.charAt(index);
            if(ch == '.'){
                if(!addData.toString().equals("")){
                    String currentObjStr = addData.toString();
                    if(currentObj instanceof Hashtable){
                        currentObj = ((Hashtable)currentObj).get(currentObjStr);
                    }
                }
                addData = new StringBuffer();
            }else if(ch == '['){
                if(!addData.toString().equals("")){
                    String currentObjStr = addData.toString();
                    if(currentObj instanceof Hashtable){
                        currentObj = ((Hashtable)currentObj).get(currentObjStr);
                    }
                }
                addData = new StringBuffer();
            }else if(ch == ']'){
                if(!addData.toString().equals("")){
                    String currentObjStr = addData.toString();
                    System.out.println(currentObjStr);
                    if(currentObj instanceof ArrayList){
                        // KEY:VALUE EX) main[CODE:D03].DATA
                        if(currentObjStr.indexOf(":")!=-1){
                            String[] match = currentObjStr.split(":");
                            ArrayList data = (ArrayList)currentObj;
                            boolean isMatch = false;
                            for(int k=0;k<data.size();k++){
                                Hashtable dataTable = (Hashtable)data.get(k);
                                if(dataTable != null && dataTable.get(match[0])!=null && ((String)dataTable.get(match[0])).equals(match[1])){
                                    currentObj = dataTable;
                                    isMatch = true;
                                    break;
                                }
                            }
                            if(!isMatch) return null;
                        }else{
                            currentObj = ((ArrayList)currentObj).get(Integer.parseInt(currentObjStr));
                        }
                    }
                }
                addData = new StringBuffer();
            }else{
                addData.append(ch);
            }
            index++;
        }
        String currentObjStr = addData.toString();
        if(!currentObjStr.equals("")){
            if(currentObj instanceof Hashtable){
                currentObj = ((Hashtable)currentObj).get(currentObjStr);
            }else if(currentObj instanceof ArrayList){
                currentObj = ((ArrayList)currentObj).get(Integer.parseInt(currentObjStr));
            }
        }
        return currentObj;
    }
    public void parseJsonText(Hashtable jsonData, String setJsonText, String current_key, ArrayList arrayData){
        //setJsonText = setJsonText.replaceAll(" ", "");
        boolean current_parser_mode = false;
        StringBuffer changeJsonText = new StringBuffer();
        for(int k=0;k<setJsonText.length();k++){
            char ch = setJsonText.charAt(k);
            if(!current_parser_mode && (ch == '"'||ch == '\'')) current_parser_mode = true;
            else if(current_parser_mode && (ch == '"'||ch == '\'')) current_parser_mode = false;
            if(ch == ' ' && !current_parser_mode) continue;
            changeJsonText.append(ch);
        }
        setJsonText = changeJsonText.toString();
        //setJsonText = setJsonText.replaceAll("\r\n", "");
        //setJsonText = setJsonText.replaceAll("\n", "");
        //setJsonText = setJsonText.replaceAll("\r", "");
        //setJsonText = setJsonText.replaceAll("\t", "");
        if(!setJsonText.equals("")) setJsonText = setJsonText.substring(1,setJsonText.length()-1);
        Hashtable currentJsonData = new Hashtable();
        ArrayList currentArrayData = new ArrayList();
        String key = "";
        String value = "";
        StringBuffer addData = new StringBuffer();
        int current_depth = 1;
        int index = 0;
        int current_mode = MODE_NOT;
        char before_ch = ' ';
        char start_ch = ' ';
        while(index < setJsonText.length()){
            char ch = setJsonText.charAt(index);
            if((ch == '"'||ch == '\'') && (start_ch == ch || start_ch == ' ') && before_ch != '\\'){
                if(current_mode == MODE_VALUE_CHK){
                    current_mode = MODE_NOT;
                    start_ch = ' ';
                }else{
                    current_mode = MODE_VALUE_CHK;
                    start_ch = ch;
                }
            }else if(ch == '{' && current_mode != MODE_VALUE_CHK){
                String startJsonSub = setJsonText.substring(index);
                String callJsonText = startJsonSub.substring(0,getMatchIndex(startJsonSub,'{','}')+1);
                parseJsonText(currentJsonData, callJsonText, key.trim(), currentArrayData);
                index = index+callJsonText.length();
                key = "";
                value = "";
            }else if(ch == ',' && current_mode != MODE_VALUE_CHK){
                value = addData.toString().trim();
                addData = new StringBuffer();
                if(key.equals("") && !value.equals("")){
                    currentArrayData.add(value.trim());
                }else if(!key.equals("") && !value.equals("")){
                    currentJsonData.put(key.trim(), value.trim());
                }
                key = "";
                value = "";
            }else if(ch == ':' && current_mode != MODE_VALUE_CHK){
                key = addData.toString().trim();
                addData = new StringBuffer();
            }else if(ch == '[' && current_mode != MODE_VALUE_CHK){
                String startJsonSub = setJsonText.substring(index);
                String callJsonText = startJsonSub.substring(0,getMatchIndex(startJsonSub,'[',']')+1).trim();
                parseJsonText(currentJsonData, callJsonText.trim(), key.trim(), currentArrayData);
                index = index+callJsonText.length();
                key = "";
                value = "";
            }else{
                addData.append(ch);
            }
            before_ch = ch;
            index++;
        }
        value = addData.toString().trim();
        if(key.equals("") && !value.equals("")){
            currentArrayData.add(value.trim());
        }else if(!key.equals("") && !value.equals("")){
            currentJsonData.put(key.trim(), value.trim());
        }
        if(!current_key.equals("")){
            if(!currentJsonData.isEmpty()){
                jsonData.put(current_key, currentJsonData);
            }else if(currentArrayData != null && currentArrayData.size() > 0){
                jsonData.put(current_key, currentArrayData);
            }
        }else{
            if(!currentJsonData.isEmpty()){
                arrayData.add(currentJsonData);
            }
            if(currentArrayData != null && currentArrayData.size() > 0){
                arrayData.add(currentArrayData);
            }
        }
    }
    public String getError(){
        System.out.println(this.errorText);
        return this.errorText;
    }
}