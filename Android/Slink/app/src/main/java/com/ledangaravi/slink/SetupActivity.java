package com.ledangaravi.slink;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.amazonaws.auth.AWSCredentialsProvider;
import com.amazonaws.mobile.client.AWSMobileClient;
import com.amazonaws.mobile.config.AWSConfiguration;
import com.amazonaws.mobileconnectors.dynamodbv2.dynamodbmapper.DynamoDBQueryExpression;
import com.amazonaws.mobileconnectors.dynamodbv2.dynamodbmapper.DynamoDBScanExpression;
import com.amazonaws.mobileconnectors.dynamodbv2.dynamodbmapper.PaginatedList;
import com.amazonaws.models.nosql.EXNAMESDO;
import com.amazonaws.models.nosql.NewsDO;
import com.amazonaws.models.nosql.WODDO;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClient;
import com.amazonaws.services.dynamodbv2.model.AttributeValue;
import com.amazonaws.services.dynamodbv2.model.ComparisonOperator;
import com.amazonaws.services.dynamodbv2.model.Condition;
import com.google.android.gms.vision.barcode.Barcode;
import com.google.gson.Gson;
import com.notbytes.barcode_reader.BarcodeReaderActivity;

import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;
import org.eclipse.paho.client.mqttv3.MqttCallbackExtended;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.json.JSONException;
import org.json.JSONObject;

import com.amazonaws.mobileconnectors.dynamodbv2.dynamodbmapper.DynamoDBMapper;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import static com.ledangaravi.slink.AuthenticatorActivity.dynamoDBMapper;


public class SetupActivity extends AppCompatActivity {
    private static final int BARCODE_READER_ACTIVITY_REQUEST = 1208;
    TextView dataReceived;
    MqttHelper mqttHelper;


    String unique_user_id = "user4";
    String content = "blank";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_setup);


        dataReceived = (TextView) findViewById(R.id.setup_mqtt_text);


        mqttHelper = new MqttHelper(getApplicationContext());
        mqttHelper.setCallback(new MqttCallbackExtended() {
            @Override
            public void connectComplete(boolean reconnect, String serverURI) {
                mqttHelper.subscribe();
            }

            @Override
            public void connectionLost(Throwable cause) {
                Toast.makeText(getApplicationContext(), R.string.mqtt_toast_disconnected, Toast.LENGTH_SHORT).show();
            }

            @Override
            public void messageArrived(String topic, MqttMessage message) throws Exception {
                Toast.makeText(getApplicationContext(),message.toString(), Toast.LENGTH_SHORT).show();
                dataReceived.setText(message.toString());
            }

            @Override
            public void deliveryComplete(IMqttDeliveryToken token) {

            }
        });

    }

    public void save(View view){
        getDefaultWOD2();
    }

    public void load(View view){
        createWOD();
    }

    public void createExNames(){
        final EXNAMESDO exNamesItem = new EXNAMESDO();

        ArrayList<String> exList = new ArrayList<>();
        exList.add("Air Squat");
        exList.add("Backward Lunge");
        exList.add("Cable Curl left");
        exList.add("Cable Curl right");
        exList.add("Crossover");
        exList.add("Crunch");
        exList.add("One-arm Cable Press left");
        exList.add("One-arm Cable Press right");
        exList.add("Outside Grip Biceps Curls");
        exList.add("Overhead Rope Extension");
        exList.add("Russian Twist");
        exList.add("Shoulder Bridge");
        exList.add("Single Arm Cable Row left");
        exList.add("Single Arm Cable Row right");
        exList.add("Standing Trunk Rotation");
        exList.add("Triceps Pushdown left");
        exList.add("Triceps Pushdown right");

        exNamesItem.setUName("slink");
        exNamesItem.setExList(exList);
        new Thread(new Runnable() {
            @Override
            public void run() {
                dynamoDBMapper.save(exNamesItem);
                // Item saved
            }
        }).start();
    }

    public void createWOD(){
        final WODDO wodItem = new WODDO();

        ArrayList<String> exList = new ArrayList<>();
        ArrayList<String> repList = new ArrayList<>();
        ArrayList<String> wList = new ArrayList<>();

        exList.add("Overhead Rope Extension");
        exList.add("Single Arm Cable Row left");
        exList.add("Single Arm Cable Row right");


        repList.add("8");
        repList.add("10");
        repList.add("10");

        wList.add("10");
        wList.add("8");
        wList.add("8");


        wodItem.setUName("slink");
        wodItem.setWODName("Demo");
        wodItem.setExList(exList);
        wodItem.setRepList(repList);
        wodItem.setWList(wList);

        new Thread(new Runnable() {
            @Override
            public void run() {
                dynamoDBMapper.save(wodItem);
                // Item saved
            }
        }).start();

    }

    public void createNews() {
        final NewsDO newsItem = new NewsDO();

        newsItem.setUserId("user3");

        newsItem.setArticleId("Article4");
        newsItem.setContent("This is the updated article content");

        new Thread(new Runnable() {
            @Override
            public void run() {
                dynamoDBMapper.save(newsItem);
                // Item saved
            }
        }).start();
    }

    public void readNews() {
        new Thread(new Runnable() {
            @Override
            public void run() {

                NewsDO newsItem = dynamoDBMapper.load(
                        NewsDO.class,
                        unique_user_id,
                        "Article3");

                //Toast.makeText(getApplicationContext(), newsItem.getContent(), Toast.LENGTH_SHORT).show();
                //dataReceived.setText(newsItem.getContent());
                // Item read
                 Log.d("News Item:", newsItem.getContent());
                 content = newsItem.getContent();
            }
        }).start();
    }


    public void deleteNews() {
        new Thread(new Runnable() {
            @Override
            public void run() {

                NewsDO newsItem = new NewsDO();

                newsItem.setUserId(unique_user_id);    //partition key

                newsItem.setArticleId("Article3");  //range (sort) key

                dynamoDBMapper.delete(newsItem);

                // Item deleted
            }
        }).start();
    }

    public void queryNews2() {
        //hash key  = partition key
        //range key = sort key
        new Thread(new Runnable() {
            @Override
            public void run() {


                NewsDO news = new NewsDO();
                news.setUserId(unique_user_id);
                news.setArticleId("Article3");

                Condition rangeKeyCondition = new Condition()
                        .withComparisonOperator(ComparisonOperator.BEGINS_WITH)
                        .withAttributeValueList(new AttributeValue().withS("Trial"));

                DynamoDBQueryExpression queryExpression = new DynamoDBQueryExpression()
                        //.withHashKeyValues(note)
                        .withRangeKeyCondition("articleId", rangeKeyCondition)
                        .withConsistentRead(false);

                PaginatedList<NewsDO> result = dynamoDBMapper.query(NewsDO.class, queryExpression);


                Gson gson = new Gson();
                StringBuilder stringBuilder = new StringBuilder();

                // Loop through query results
                for (int i = 0; i < result.size(); i++) {
                    String jsonFormOfItem = gson.toJson(result.get(i));
                    stringBuilder.append(jsonFormOfItem + "\n\n");
                }

                // Add your code here to deal with the data result
                Log.e("Query result: ", stringBuilder.toString());

                if (result.isEmpty()) {
                    // There were no items matching your query.
                    Log.e("Query result: ", "nothing :(");
                }
            }
        }).start();

    }

    public void queryNews() {
        Log.e("Query result: ", "start");
        //hash key  = partition key
        //range key = sort key
        new Thread(new Runnable() {
            @Override
            public void run() {
                Log.e("Query result: ", "run");
                HashMap<String, AttributeValue> eav = new HashMap<String, AttributeValue>();
                eav.put(":v2", new AttributeValue().withS("user3"));

                DynamoDBScanExpression scanExpression = new DynamoDBScanExpression()
                        .withFilterExpression("begins_with(userId,:v2)")
                        .withExpressionAttributeValues(eav);


                List<NewsDO> result =  dynamoDBMapper.scan(NewsDO.class, scanExpression);

                Gson gson = new Gson();
                StringBuilder stringBuilder = new StringBuilder();

                // Loop through query results
                for (int i = 0; i < result.size(); i++) {
                    String jsonFormOfItem = gson.toJson(result.get(i));
                    stringBuilder.append(jsonFormOfItem + "\n\n");
                }

                // Add your code here to deal with the data result
                Log.e("Query result: ", stringBuilder.toString());

                if (result.isEmpty()) {
                    // There were no items matching your query.
                    Log.e("Query result: ", "nothing :(");
                }

            }
        }).start();

    }


    public void getDefaultWOD2() {
        //hash key  = partition key
        //range key = sort key
        new Thread(new Runnable() {
            @Override
            public void run() {
                WODDO wodItem = new WODDO();
                wodItem.setUName("slink");
                wodItem.setWODName("m");


                Condition rangeKeyCondition = new Condition()
                        .withComparisonOperator(ComparisonOperator.BEGINS_WITH)
                        .withAttributeValueList(new AttributeValue().withS("m"));

                DynamoDBQueryExpression queryExpression = new DynamoDBQueryExpression()
                        .withHashKeyValues(wodItem)
                        //.withRangeKeyCondition("WOD_name", rangeKeyCondition)
                        .withConsistentRead(false);

                PaginatedList<WODDO> result = dynamoDBMapper.query(WODDO.class, queryExpression);


                Gson gson = new Gson();
                StringBuilder stringBuilder = new StringBuilder();

                // Loop through query results
                for (int i = 0; i < result.size(); i++) {
                    String jsonFormOfItem = gson.toJson(result.get(i));
                    stringBuilder.append(jsonFormOfItem + "\n\n");
                }

                // Add your code here to deal with the data result
                Log.e("Query result: ", stringBuilder.toString());

                if (result.isEmpty()) {
                    // There were no items matching your query.
                    Log.e("Query result: ", "nothing :(");
                }
            }
        }).start();

    }





    public void publish(View view){
        EditText editText = (EditText) findViewById(R.id.setup_message_text);
        JSONObject json = new JSONObject();
        try {

            json.put("name", "emil");
            json.put("username", "emil111");
            json.put("age", "111");

        } catch (JSONException e) {
            Log.e("MYAPP", "unexpected JSON exception", e);
            // Do something to recover ... or kill the app.
        }


        mqttHelper.payload = json;
        mqttHelper.publish();
    }

    public void scanQR(View view) {
        Intent launchIntent = BarcodeReaderActivity.getLaunchIntent(this, true, false);
        startActivityForResult(launchIntent, BARCODE_READER_ACTIVITY_REQUEST);
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (resultCode != Activity.RESULT_OK) {
            Toast.makeText(this, R.string.setup_scan_fail, Toast.LENGTH_SHORT).show();
            return;
        }

        if (requestCode == BARCODE_READER_ACTIVITY_REQUEST && data != null) {
            Barcode barcode = data.getParcelableExtra(BarcodeReaderActivity.KEY_CAPTURED_BARCODE);
            Toast.makeText(this, barcode.rawValue, Toast.LENGTH_SHORT).show();
            TextView textView = findViewById(R.id.setup_scan_text);
            textView.setText(barcode.rawValue);
        }

    }
}
