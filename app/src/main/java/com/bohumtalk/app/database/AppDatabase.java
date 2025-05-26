package com.bohumtalk.app.database;

import android.content.Context;

import androidx.room.Database;
import androidx.room.Room;
import androidx.room.RoomDatabase;

import com.bohumtalk.app.dao.AlarmDao;
import com.bohumtalk.app.dao.TokenDao;
import com.bohumtalk.app.dao.UserDao;
import com.bohumtalk.app.entity.AlarmEntity;
import com.bohumtalk.app.entity.TokenEntity;
import com.bohumtalk.app.entity.UserEntity;

//@Database(entities = {UserEntity.class}, version = 1)
@Database(entities = {AlarmEntity.class, UserEntity.class, TokenEntity.class}, version = 1)
public abstract class AppDatabase extends RoomDatabase {

    public abstract AlarmDao alaramDao();
    public abstract UserDao userDao();
    public abstract TokenDao tokenDao();
    private static volatile AppDatabase INSTANCE;

    public static AppDatabase getInstance(Context context) {
        if (INSTANCE == null) {
            synchronized (AppDatabase.class) {
                if (INSTANCE == null) {
                    INSTANCE = Room.databaseBuilder(
                            context.getApplicationContext(),
                            AppDatabase.class, "BHT_DATABASE"
                    ).build();
                }
            }
        }
        return INSTANCE;
    }
}