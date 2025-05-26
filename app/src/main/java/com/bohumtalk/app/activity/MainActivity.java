package com.bohumtalk.app.activity;

import android.app.ComponentCaller;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.webkit.*;
import android.widget.Toast;

import androidx.activity.OnBackPressedCallback;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.bohumtalk.app.R;
import com.bohumtalk.app.custom.CustomWebAppInterface;
import com.bohumtalk.app.custom.CustomWebViewClient;
import com.google.firebase.messaging.FirebaseMessaging;

import org.json.JSONException;
import org.json.JSONObject;

public class MainActivity extends AppCompatActivity {
    private static final String TAG = MainActivity.class.getSimpleName();

    private final String APP_BRIDGE = "bohumTalkInterface";
    private final String LOAD_URL = "https://piaolin1116.github.io";
    private long backPressedTime = 0; // 뒤로 가기 버튼을 누른 시간 저장
    private static final long BACK_PRESS_INTERVAL = 2000; // 2초 이내에 두 번 눌러야 종료

    private WebView webView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        FirebaseMessaging.getInstance().getToken()
                .addOnCompleteListener(task -> {
                    if (!task.isSuccessful()) {
                        Log.w(TAG, "Fetching FCM registration token failed", task.getException());
                        return;
                    }
                    String token = task.getResult();
                    Log.d(TAG, "FCM Token: " + token);
                    //dYSXAQPkQDah5IxKX8laGo:APA91bGsXPnLlP0LBXDEkb_FwAQk_X7tEi-ll1VeBuGd5dT3EzNYjI_ITuZIUfJdLIwqzAQoTwqWJ5YrUaz3xygwx09AN9HY3341ym5E7vxyvuAda3s9bxQ
                    //dYLr-HFtQMmASySfoyEFEw:APA91bF_ROSRenWbAuW08bPUEBQV4ADaoIzN8M0IG1bhb545g9uIiCWs64XosQ19-wTTaDIEgEtg8-7r4GqAQ1YMbj3637UBMuzlEdzgvunhkPEMxujARk8
                    //fPhG37QmS8uyGWuq9nWLyG:APA91bG6jkipFJNgjvvGyBNY8r_dA-vixqpN7CotfV9FVwZFMRoDLAhVVuR3c9ilS0lIYdrHN_TGUAhLaVlw1BOpX7CKi76PI34aSz-AbTd1UKkSLypbtqw
                });

        //Android 15(API 레벨 35) 이상을 타겟팅하는 앱은 기본적으로 시스템 UI 경계를 넘어 전체 디스플레이 영역을 활용한다. 이를 edge-to-edge라고 표현한다. 윈도우는 전체 너비와 높이를 포함하고, 시스템 바 뒷 영역 또한 포함한다
        //EdgeToEdge.enable(this);
        setContentView(R.layout.activity_main);

        webView = findViewById(R.id.webView);
        webView.getSettings().setJavaScriptEnabled(true); // JavaScript 사용 설정( Default : FALSE )
        //webView.getSettings().setJavaScriptCanOpenWindowsAutomatically(true);    // JavaScript 새 창 열기 제어 설정( Default : FALSE )
        //webView.getSettings().setBuiltInZoomControls(true);   //  줌 아이콘 설정( Default : FALSE )
        //webView.getSettings().setSupportZoom(true);   // 확대 / 축소 기능 사용 설정( Default : FALSE )
        //webView.getSettings().setAllowFileAccess(true);   // WebView 내의 파일 접근 설정( Default : FALSE )
        //webView.getSettings().setAllowContentAccess(false); // 웹 콘텐츠 접근 차단
        //webView.getSettings().setAllowFileAccessFromFileURLs(false); // 파일 URL 간의 접근 제한
        //webView.getSettings().setAllowUniversalAccessFromFileURLs(false); // 모든 파일 URL 접근 제한
        //webView.getSettings().setSupportMultipleWindows(true);    // 여러 개의 윈도우를 사용할 수 있도록 설정( Default : FALSE )
        //webView.getSettings().setDatabaseEnabled(true);   // DataBase를 사용할 수 있도록 설정( Default : FALSE )
        //webView.getSettings().setBlockNetworkImage(false); // NetWork의 이미지 리소스를 사용할 수 있도록 설정( Default : FALSE )
        //webView.getSettings().setBlockNetworkLoads(false);    // NetWork의 외부 리소스를 로드 할 수 있도록 설정( Default : FALSE )
        //webView.getSettings().setLoadsImagesAutomatically(true);  // WebView가 App에 등록되어 있는 이미지 리소를 자동으로 로드하도록 설정( Default : TRUE )
        //webView.getSettings().setDomStorageEnabled(true); // DOM 저장소 사용 설정( Default : FALSE )
        webView.getSettings().setLoadWithOverviewMode(true); // Web Page의 내용이 WebView의 크기에 맞춰 축소되어 표시 되도록 설정( Default : FALSE )
        webView.getSettings().setUseWideViewPort(true); // Web Page가 설정한 viewport를 기준으로 레이아웃을 조정( Default : FALSE )
        //webView.getSettings().setTextZoom(100);  // 글자 크기를 고정(이 부분은 시스템 글자 크기에 영향받지 않게 설정)
        // WebView가 Web Page를 로드할 때 네트워크 요청과 캐시를 어떻게 사용할지 결정
        webView.getSettings().setCacheMode(WebSettings.LOAD_DEFAULT); // `WebSettings.LOAD_DEFAULT` 네트워크가 사용 가능할 때는 네트워크를 사용
        // webSettings.setCacheMode(WebSettings.LOAD_NO_CACHE);    // WebView가 캐시를 사용하지 않고매번 서버에 데이터 요청

        //HTTPS가 아닌 HTTP를 차단하면 보안 강화돼
        if (false && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            webView.getSettings().setSafeBrowsingEnabled(true); // 안전한 브라우징 활성화 (API 26+)
        }

        // JavaScript 인터페이스 추가
        webView.addJavascriptInterface(new CustomWebAppInterface(this, webView), APP_BRIDGE);
        //webView.getSettings().setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW); // HTTP/HTTPS 혼합 컨텐츠 허용 (필요한 경우)

        String defaultUserAgent = webView.getSettings().getUserAgentString();

        try {
            PackageInfo pi = getPackageManager().getPackageInfo(getPackageName(),0);

            int versionCode = pi.versionCode;
            String versionName = pi.versionName;
            defaultUserAgent += " BohumTalk " + versionCode+"/"+versionName;
        } catch (PackageManager.NameNotFoundException e) {
            throw new RuntimeException(e);
        }
        webView.getSettings().setUserAgentString(defaultUserAgent);

        Intent schemeIntent = getIntent();
        Uri data = schemeIntent.getData();
        String pendingURL = null;   // 노티랑 따로

        if(data != null) {
            Log.d(TAG, "URL SCHEME DATA : " + pendingURL);
            //webView.evaluateJavascript("javascript:nativeMessage('"+data.toString()+"');",null);
            pendingURL = data.toString();
        }else if(schemeIntent.getExtras() != null){
            Bundle extras = getIntent().getExtras();
            JSONObject json = new JSONObject();
            for(String key : extras.keySet()){
                Object value = extras.get(key);
                try {
                    json.put(key,value);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }

            pendingURL = json.toString();
            Log.d(TAG,"NOTIFICATION DATA : " + pendingURL);
        }else{
            Log.d(TAG,"intent data is null");
        }

        //웹뷰환경을 구글 크롬 브라우저에 맞춰서 쾌적하게 돌리기 위해 하는 추가 세팅
        //앱이 실행중에도 스키마로 접근하면 onCreate 다시 실행해서 문제없는듯
        webView.setWebChromeClient(new WebChromeClient());
        webView.setWebViewClient(new CustomWebViewClient(this,pendingURL));

        webView.loadUrl(LOAD_URL);

        // 뒤로가기 버튼 콜백 처리
        getOnBackPressedDispatcher().addCallback(this, new OnBackPressedCallback(true) {
            @Override
            public void handleOnBackPressed() {
                if (webView.canGoBack()) {
                    webView.goBack();
                } else {
                    long currentTime = System.currentTimeMillis();
                    if (currentTime - backPressedTime < BACK_PRESS_INTERVAL) {
                        finish(); // 앱 종료
                    }else{
                        Toast.makeText(MainActivity.this, "한 번 더 누르면 종료됩니다.", Toast.LENGTH_SHORT).show();
                        backPressedTime = currentTime;
                    }
                }
            }
        });
    }
}