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

@DynamoDBTable(tableName = "slink-mobilehub-286091421-DEVICES")

public class DEVICESDO {
    private String _deviceID;
    private String _wODName;
    private List<String> _exList;
    private List<String> _repList;
    private String _uName;
    private List<String> _wList;

    @DynamoDBHashKey(attributeName = "device_ID")
    @DynamoDBAttribute(attributeName = "device_ID")
    public String getDeviceID() {
        return _deviceID;
    }

    public void setDeviceID(final String _deviceID) {
        this._deviceID = _deviceID;
    }
    @DynamoDBAttribute(attributeName = "WOD_name")
    public String getWODName() {
        return _wODName;
    }

    public void setWODName(final String _wODName) {
        this._wODName = _wODName;
    }
    @DynamoDBAttribute(attributeName = "exList")
    public List<String> getExList() {
        return _exList;
    }

    public void setExList(final List<String> _exList) {
        this._exList = _exList;
    }
    @DynamoDBAttribute(attributeName = "repList")
    public List<String> getRepList() {
        return _repList;
    }

    public void setRepList(final List<String> _repList) {
        this._repList = _repList;
    }
    @DynamoDBAttribute(attributeName = "u_name")
    public String getUName() {
        return _uName;
    }

    public void setUName(final String _uName) {
        this._uName = _uName;
    }
    @DynamoDBAttribute(attributeName = "wList")
    public List<String> getWList() {
        return _wList;
    }

    public void setWList(final List<String> _wList) {
        this._wList = _wList;
    }

}
