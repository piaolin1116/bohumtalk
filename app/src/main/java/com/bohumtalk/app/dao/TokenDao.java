package com.bohumtalk.app.dao;

import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.Query;
import androidx.room.Update;

import com.bohumtalk.app.entity.TokenEntity;

@Dao
public interface TokenDao {
    @Insert
    void insert(TokenEntity token);

    @Update
    void update(TokenEntity token);

    @Query("SELECT * FROM TA_ACCESSTOKEN WHERE USER_IDX = :userIdx AND LOGIN_COMPANY = :loginCompany AND :currentTime BETWEEN VALID_FROM_DATE AND VALID_END_DATE")
    TokenEntity getUserToken(String userIdx, String loginCompany, long currentTime);

}
