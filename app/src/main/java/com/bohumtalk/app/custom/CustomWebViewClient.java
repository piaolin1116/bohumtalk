package com.bohumtalk.app.custom;


import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.annotation.NonNull;

import java.net.URISyntaxException;

/*
 * WebViewClient
 *  • Web Page의 로딩과 네비게이션 이벤트를 관리하고, WebView 내에서 링크 클릭, URL 로드등을 제어하는 클래스
 *  • 페이지 로드 이벤트 처리
 *  • 링크 클릭 제어
 *  • HTTP, HTTPS 인증 및 오류 처리
 */
public class CustomWebViewClient extends WebViewClient {
    private static final String TAG = CustomWebViewClient.class.getSimpleName();
    private final Context context;
    private String pendingURL = null;
    public CustomWebViewClient(Context context, String pendingURL) {
        this.context = context;
        this.pendingURL = pendingURL;
    }

    @Override
    public void onPageFinished(WebView view, String url) {
        super.onPageFinished(view, url);
        if(pendingURL != null){
            view.evaluateJavascript("javascript:nativeMessage('" + pendingURL + "');", null);
            pendingURL = null;
        }
    }

    @Override
    public boolean shouldOverrideUrlLoading(@NonNull WebView view, @NonNull WebResourceRequest request) {
        String url = request.getUrl().toString();
        Log.d(TAG, url);

        if("intent".equals(request.getUrl().getScheme())) {
            try {
                Intent intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME);

                if(intent.resolveActivity(context.getPackageManager()) != null) {
                    context.startActivity(intent);
                    Log.d(TAG, "ACTIVITY : " + intent.getPackage());
                    return true;
                }else{
                    String packageName = intent.getPackage();
                    if (packageName != null) {
                        Intent playStoreIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + packageName));
                        if(playStoreIntent.resolveActivity(context.getPackageManager()) != null) {
                            context.startActivity(playStoreIntent);
                            Log.d(TAG, "Play 스토어로 재전송 중 : " + packageName);
                        } else {
                            playStoreIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=" + packageName));
                            context.startActivity(playStoreIntent);
                            Log.d(TAG, "Play 스토어 Web Site로 재전송 중 : " + packageName);
                        }
                    }
                    return true;
                }
            } catch (URISyntaxException e) {
                Log.e(TAG, "잘못된 인텐트 요청", e);
            }
        }

        return false; // 나머지 URL 로딩 처리
    }
}