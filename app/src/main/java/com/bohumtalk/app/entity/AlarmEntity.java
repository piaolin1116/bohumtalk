package com.bohumtalk.app.entity;

import androidx.annotation.NonNull;
import androidx.room.ColumnInfo;
import androidx.room.Entity;

@Entity(
    tableName = "TA_ALARMLIST",
    primaryKeys = {"USER_IDX", "ALARM_IDX"}
)
public class AlarmEntity {
    //@PrimaryKey(autoGenerate = true)
    //public int id;

    @ColumnInfo(name = "USER_IDX")
    @NonNull
    public String userIdx;

    @ColumnInfo(name = "ALARM_IDX")
    @NonNull
    public String alarmIdx;

    @ColumnInfo(name = "TITLE")
    public String title;

    @ColumnInfo(name = "CONTENT")
    public String content;

    @ColumnInfo(name = "IMAGE")
    public String image;

    @ColumnInfo(name = "ICON")
    public String icon;

    @ColumnInfo(name = "ALARM_DATE")
    public String alarmDate;

    @ColumnInfo(name = "READ_DATE")
    public String readDate;

    @ColumnInfo(name = "ALARM_DATA")
    public String alaramData;
}
