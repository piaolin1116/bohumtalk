package com.bohumtalk.app.notification;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;

import com.bohumtalk.app.R;
import com.google.firebase.messaging.RemoteMessage;
import com.google.firebase.messaging.FirebaseMessagingService;

public class CustomFirebaseMessagingService extends FirebaseMessagingService {
    private final String TAG = getClass().getSimpleName();
    @Override
    public void onNewToken(@NonNull String token) {
        Log.d(TAG, "Refreshed token: " + token);

        // If you want to send messages to this application instance or
        // manage this apps subscriptions on the server side, send the
        // FCM registration token to your app server.

        //새 토큰이 생성될 때마다 onNewToken 콜백이 호출됩니다.
        //sendRegistrationToServer(token);

    }
    @Override
    public void onMessageReceived(@NonNull RemoteMessage remoteMessage) {
        super.onMessageReceived(remoteMessage);

        Log.d(TAG, "From: " + remoteMessage.getFrom());
        // Check if message contains a data payload.

        String title = "";
        String body = "";
        if (remoteMessage.getData().size() > 0) {
            Log.d(TAG, "Message data payload: " + remoteMessage.getData());


            title = remoteMessage.getData().get("title");
            body = remoteMessage.getData().get("body");



            if (/* Check if data needs to be processed by long running job */ true) {
                // For long-running tasks (10 seconds or more) use WorkManager.
                //scheduleJob();
            } else {
                // Handle message within 10 seconds
                //handleNow();
            }
        }

        //if (remoteMessage.getNotification() != null) {
            Log.d(TAG, "Message Notification: " + remoteMessage.getNotification());
            showNotification(title, body);
        //}
    }

    private void showNotification(String title, String message) {
        NotificationManager notificationManager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);

        //채널아이디이이이이이이/???
        String channelId = getApplicationContext().getPackageName() + ".notification";

        Log.d(TAG,"getApplicationContext().getPackageName() : " + getApplicationContext().getPackageName());

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(channelId, "FCM Notifications",
                    NotificationManager.IMPORTANCE_HIGH);
            notificationManager.createNotificationChannel(channel);
        }



        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, channelId)
                //.setSmallIcon(R.drawable.app_icon)
                .setSmallIcon(R.drawable.ic_notification)
                .setContentTitle(title)
                .setContentText(message)
                .setAutoCancel(true);

        int notificationId = (int) System.currentTimeMillis();
        notificationManager.notify(notificationId, builder.build());//sendNo 여기에 꼽아야함, 필수는 아니지
    }
}