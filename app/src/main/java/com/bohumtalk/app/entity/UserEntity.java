package com.bohumtalk.app.entity;

import androidx.annotation.NonNull;
import androidx.room.ColumnInfo;
import androidx.room.Entity;

@Entity(
    tableName = "TA_USER",
    primaryKeys = {"SNS_ID","USER_IDX"}
)
public class UserEntity {
    @ColumnInfo(name = "SNS_ID")
    @NonNull
    public String snsId;
    @ColumnInfo(name = "USER_IDX")
    @NonNull
    public String userIdx;

    @ColumnInfo(name = "ALARM_YN")
    public String alarmYn;

    @ColumnInfo(name = "FIREBASE_TOKEN")
    @NonNull
    public String firebaseToken;

    @ColumnInfo(name = "LOGIN_DATE")
    public String loginDate;

    @ColumnInfo(name = "LOGOUT_DATE")
    public String logoutDate;


}
