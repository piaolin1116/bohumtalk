package com.bohumtalk.app.custom;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;

import android.util.Log;
import android.webkit.JavascriptInterface;
import android.webkit.WebView;


import com.bohumtalk.app.database.AppDatabase;
import com.bohumtalk.app.entity.AlarmEntity;
import com.bohumtalk.app.util.Common;
import com.bohumtalk.app.util.JsonParsing;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;

public class CustomWebAppInterface {
    private final String TAG = getClass().getSimpleName();

    Context context;
    private WebView webView;
    private AppDatabase db;

    // 생성자
    public CustomWebAppInterface(Context context, WebView webView) {
        this.context = context;
        this.webView = webView;

        db = AppDatabase.getInstance(context);
    }

    @JavascriptInterface
    public void postMessage(String data) {
        Log.d(TAG, "postMessage() request " + data);

        Hashtable resultTable = null;
        JsonParsing jp = new JsonParsing();
        jp.setJsonText(data);
        jp.parsing();
        Hashtable requestTable = jp.getMainData();
        String vuexCallType = Common.getValue(requestTable, "vuexCallType");
        switch (vuexCallType) {
            case "getAccessToken": //고객관련 네이티브 저장사항 요청
                resultTable = new Hashtable();
                sendToWeb("USER_DELETE",resultTable);
                break;
            case "getNotiList": //알림리스트 요청
                getNotiList(requestTable);
                break;
            case "deleteCustomInfo": //회원탈퇴 요청

                break;
            case "changeNotiSetting": //알림설정 변경 요청
                openAppSettings();
                break;
            case "changeAccessToken": //고객 토큰 변경 요청
                String accessToken = Common.getValue(requestTable, "accessToken");

                break;
            case "vuexCallUrl": //링크 처리 요청
                String url = Common.getValue(requestTable, "url");
                openBrowser(url);
                break;
            case "customLogout": //로그아웃 요청

                break;
        }
    }
    public static ArrayList<Hashtable<String, Object>> convertToHashtableList(ArrayList<AlarmEntity> entityList) {
        ArrayList<Hashtable<String, Object>> resultList = new ArrayList<>();

        for (Object entity : entityList) {
            Hashtable<String, Object> table = new Hashtable<>();
            Field[] fields = entity.getClass().getDeclaredFields();

            for (Field field : fields) {
                field.setAccessible(true); // private 필드 접근 가능하도록 설정
                try {
                    if(field.get(entity) != null) table.put(field.getName(), field.get(entity)); // 필드 이름과 값을 매핑
                } catch (IllegalAccessException e) {
                    e.printStackTrace();
                }
            }

            resultList.add(table);
        }

        return resultList;
    }

    private void getNotiList(Hashtable paramTable) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                Hashtable resultTable = new Hashtable();
                String searchType = Common.getValue(paramTable, "searchType");
                int from = 0;
                int to = 0;
                try {
                    from = Integer.parseInt(Common.getValue(paramTable, "from"));
                    to = Integer.parseInt(Common.getValue(paramTable, "to"));
                }catch (Exception e){
                    e.printStackTrace();
                }

                String userIdx = ""; // 넌 어디에서 가져오니?
                if(searchType.equals("alarmlist")){
                    List<AlarmEntity> entities = db.alaramDao().getAlarmList("" ,from, to);
                    ArrayList<AlarmEntity> notiList = new ArrayList<>(entities);

                    if(notiList == null || notiList.size() == 0){
                        notiList = new ArrayList();
                        AlarmEntity item = new AlarmEntity();
                        item.alarmIdx = "1";
                        item.title = "4월이슈";
                        item.content = "보험료인상";
                        notiList.add(item);
                    }
                    ArrayList<Hashtable<String, Object>> convertedList = convertToHashtableList(notiList);

                    resultTable.put("notiList",convertedList);
                    sendToWeb("",resultTable);
                }
            }
        }).start();
    }

    private void openAppSettings(){
        Intent intent = new Intent(android.provider.Settings.ACTION_APP_NOTIFICATION_SETTINGS);
        intent.putExtra("android.provider.extra.APP_PACKAGE", context.getPackageName());
        context.startActivity(intent);
    }
    private void openBrowser(String url){
        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
        context.startActivity(intent); // UI 관련 작업이므로 메인 스레드에서 실행해야 함
    }

    private void sendToWeb(String nativeCallType, Hashtable data) {
        webView.post(new Runnable() {
            @Override
            public void run() {
                Hashtable resultTable = new Hashtable();
                resultTable.put("nativeCallType",nativeCallType);
                resultTable.put("param",data);

                JsonParsing jp = new JsonParsing();
                jp.setJsonObj(resultTable);
                jp.parseToText();

                Log.d(TAG,""+resultTable);

                webView.evaluateJavascript("javascript:nativeMessage('" + jp.getMakeText() + "');", null);
            }
        });
    }
}