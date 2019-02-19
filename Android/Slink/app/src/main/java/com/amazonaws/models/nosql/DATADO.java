package com.amazonaws.models.nosql;

import com.amazonaws.mobileconnectors.dynamodbv2.dynamodbmapper.DynamoDBAttribute;
import com.amazonaws.mobileconnectors.dynamodbv2.dynamodbmapper.DynamoDBHashKey;
import com.amazonaws.mobileconnectors.dynamodbv2.dynamodbmapper.DynamoDBIndexHashKey;
import com.amazonaws.mobileconnectors.dynamodbv2.dynamodbmapper.DynamoDBIndexRangeKey;
import com.amazonaws.mobileconnectors.dynamodbv2.dynamodbmapper.DynamoDBRangeKey;
import com.amazonaws.mobileconnectors.dynamodbv2.dynamodbmapper.DynamoDBTable;

import java.util.List;
import java.util.Map;
import java.util.Set;

@DynamoDBTable(tableName = "slink-mobilehub-286091421-DATA")

public class DATADO {
    private String _uName;
    private String _timePlusNum;
    private String _wODName;
    private String _exName;
    private List<String> _forceList;
    private Double _reps;
    private List<String> _speedList;
    private String _timestampFirst;
    private String _timestampLast;
    private Double _weight;

    @DynamoDBHashKey(attributeName = "u_name")
    @DynamoDBAttribute(attributeName = "u_name")
    public String getUName() {
        return _uName;
    }

    public void setUName(final String _uName) {
        this._uName = _uName;
    }
    @DynamoDBRangeKey(attributeName = "time_plus_num")
    @DynamoDBAttribute(attributeName = "time_plus_num")
    public String getTimePlusNum() {
        return _timePlusNum;
    }

    public void setTimePlusNum(final String _timePlusNum) {
        this._timePlusNum = _timePlusNum;
    }
    @DynamoDBAttribute(attributeName = "WOD_name")
    public String getWODName() {
        return _wODName;
    }

    public void setWODName(final String _wODName) {
        this._wODName = _wODName;
    }
    @DynamoDBAttribute(attributeName = "ex_name")
    public String getExName() {
        return _exName;
    }

    public void setExName(final String _exName) {
        this._exName = _exName;
    }
    @DynamoDBAttribute(attributeName = "forceList")
    public List<String> getForceList() {
        return _forceList;
    }

    public void setForceList(final List<String> _forceList) {
        this._forceList = _forceList;
    }
    @DynamoDBAttribute(attributeName = "reps")
    public Double getReps() {
        return _reps;
    }

    public void setReps(final Double _reps) {
        this._reps = _reps;
    }
    @DynamoDBAttribute(attributeName = "speedList")
    public List<String> getSpeedList() {
        return _speedList;
    }

    public void setSpeedList(final List<String> _speedList) {
        this._speedList = _speedList;
    }
    @DynamoDBAttribute(attributeName = "timestamp_first")
    public String getTimestampFirst() {
        return _timestampFirst;
    }

    public void setTimestampFirst(final String _timestampFirst) {
        this._timestampFirst = _timestampFirst;
    }
    @DynamoDBAttribute(attributeName = "timestamp_last")
    public String getTimestampLast() {
        return _timestampLast;
    }

    public void setTimestampLast(final String _timestampLast) {
        this._timestampLast = _timestampLast;
    }
    @DynamoDBAttribute(attributeName = "weight")
    public Double getWeight() {
        return _weight;
    }

    public void setWeight(final Double _weight) {
        this._weight = _weight;
    }

}
