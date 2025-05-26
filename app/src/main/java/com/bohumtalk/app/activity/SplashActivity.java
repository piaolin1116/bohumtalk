package com.bohumtalk.app.activity;


import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;

import androidx.appcompat.app.AppCompatActivity;
import com.bohumtalk.app.R;

public class SplashActivity extends AppCompatActivity {
    private static final String TAG = SplashActivity.class.getSimpleName();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent(SplashActivity.this, MainActivity.class);
                //스플래시 스크린이 먼저 실행되서 메인액티비티에서 데이터 유실
                if(getIntent() != null) {
                    Log.d(TAG,"intent getAction : " + getIntent().getAction());
                    Log.d(TAG,"intent getData : " + getIntent().getData());
                    Log.d(TAG,"intent getExtras : " + getIntent().getExtras());

                    intent.setAction(getIntent().getAction());
                    intent.setData(getIntent().getData());
                    if(getIntent().getExtras() != null) {
                        intent.putExtras(getIntent().getExtras());
                    }
                }
                startActivity(intent);
                finish();
            }
        }, 3000);
    }
}