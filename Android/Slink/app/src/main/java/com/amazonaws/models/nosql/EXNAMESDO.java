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

@DynamoDBTable(tableName = "slink-mobilehub-286091421-EX_NAMES")

public class EXNAMESDO {
    private String _uName;
    private List<String> _exList;

    @DynamoDBHashKey(attributeName = "u_name")
    @DynamoDBAttribute(attributeName = "u_name")
    public String getUName() {
        return _uName;
    }

    public void setUName(final String _uName) {
        this._uName = _uName;
    }
    @DynamoDBAttribute(attributeName = "exList")
    public List<String> getExList() {
        return _exList;
    }

    public void setExList(final List<String> _exList) {
        this._exList = _exList;
    }

}
