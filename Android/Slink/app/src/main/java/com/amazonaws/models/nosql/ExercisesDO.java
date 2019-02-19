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

@DynamoDBTable(tableName = "slink-mobilehub-286091421-Exercises")

public class ExercisesDO {
    private String _exerciseName;

    @DynamoDBHashKey(attributeName = "ExerciseName")
    @DynamoDBAttribute(attributeName = "ExerciseName")
    public String getExerciseName() {
        return _exerciseName;
    }

    public void setExerciseName(final String _exerciseName) {
        this._exerciseName = _exerciseName;
    }

}
