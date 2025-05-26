package com.bohumtalk.app.entity;

import androidx.annotation.NonNull;
import androidx.room.ColumnInfo;
import androidx.room.Entity;

@Entity(
    tableName = "TA_ACCESSTOKEN",
    primaryKeys = {"USER_IDX", "ACCESSTOKEN","LOGIN_COMPANY"}
)

public class TokenEntity {
    //@PrimaryKey(autoGenerate = true)
    //public int id;

    @ColumnInfo(name = "USER_IDX")
    @NonNull
    public String userIdx;

    @ColumnInfo(name = "ACCESSTOKEN")
    @NonNull
    public String accessToken;

    @ColumnInfo(name = "LOGIN_COMPANY")
    @NonNull
    public String loginCompany;

    @ColumnInfo(
        name = "VALID_FROM_DATE",
        defaultValue = "CURRENT_TIMESTAMP"
    )
    public long validFromDate;

    @ColumnInfo(name = "VALID_END_DATE")
    public long validEndDate;
    /*
YourEntity entity = new YourEntity();
entity.name = "테스트 데이터";
entity.createdAt = System.currentTimeMillis(); // 현재 timestamp 저장
yourDao.insert(entity);
     */
}
