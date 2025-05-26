package com.bohumtalk.app.dao;

import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.Query;

import com.bohumtalk.app.entity.AlarmEntity;

import java.util.List;

@Dao
public interface AlarmDao {
    @Insert
    void insert(AlarmEntity alarm);

    @Query("UPDATE TA_ALARMLIST SET READ_DATE = :currentTime WHERE USER_IDX = :userIdx")
    void readAllUnread(String userIdx, long currentTime);

    @Query("DELETE FROM TA_ALARMLIST WHERE USER_IDX = :userIdx")
    void deleteAll(String userIdx);

    /*
        알림리스트에서 표기
        지정갯수만큼
        대신에 READ_DATE 가 NULL인건 모두 현재 날짜로 업데이트
     */
    @Query("SELECT * FROM TA_ALARMLIST WHERE USER_IDX = :userIdx ORDER BY ALARM_IDX DESC LIMIT :from OFFSET :to")
    List<AlarmEntity> getAlarmList(String userIdx, int from, int to);

    /*
        메인에 읽지 않은 알림 갯수 표기
     */
    @Query("SELECT COUNT(*) FROM TA_ALARMLIST WHERE USER_IDX = :userIdx AND READ_DATE IS NULL")
    int getUnreadCount(String userIdx);
}
