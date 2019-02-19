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

@DynamoDBTable(tableName = "slink-mobilehub-286091421-Routines")

public class RoutinesDO {
    private String _routineName;
    private List<String> _exerciseList;
    private List<String> _repList;
    private List<String> _weightList;

    @DynamoDBHashKey(attributeName = "routineName")
    @DynamoDBAttribute(attributeName = "routineName")
    public String getRoutineName() {
        return _routineName;
    }

    public void setRoutineName(final String _routineName) {
        this._routineName = _routineName;
    }
    @DynamoDBAttribute(attributeName = "exerciseList")
    public List<String> getExerciseList() {
        return _exerciseList;
    }

    public void setExerciseList(final List<String> _exerciseList) {
        this._exerciseList = _exerciseList;
    }
    @DynamoDBAttribute(attributeName = "repList")
    public List<String> getRepList() {
        return _repList;
    }

    public void setRepList(final List<String> _repList) {
        this._repList = _repList;
    }
    @DynamoDBAttribute(attributeName = "weightList")
    public List<String> getWeightList() {
        return _weightList;
    }

    public void setWeightList(final List<String> _weightList) {
        this._weightList = _weightList;
    }

}
