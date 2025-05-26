package com.bohumtalk.app.dao;

import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.Query;
import androidx.room.Update;

import com.bohumtalk.app.entity.UserEntity;

@Dao
public interface UserDao {

    //https://developer.android.com/training/data-storage/room/accessing-data?hl=ko#java

    @Insert
    //void insertAll(UserEntity... user);
    void insert(UserEntity user);

    @Update
    void update(UserEntity user);

    @Query("DELETE FROM TA_USER WHERE USER_IDX = :userIdx")
    void deleteUser(String userIdx);

    @Query("SELECT * FROM TA_USER WHERE USER_IDX = :userIdx")
    UserEntity getUserInfo(String userIdx);
}