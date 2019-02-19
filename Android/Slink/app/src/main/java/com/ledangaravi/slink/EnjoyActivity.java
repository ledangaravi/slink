package com.ledangaravi.slink;

import android.app.Activity;
import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;


import com.amazonaws.models.nosql.DEVICESDO;
import com.amazonaws.models.nosql.NewsDO;
import com.amazonaws.models.nosql.WODDO;
import com.google.android.gms.vision.barcode.Barcode;
import com.notbytes.barcode_reader.BarcodeReaderActivity;

import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;
import org.eclipse.paho.client.mqttv3.MqttCallbackExtended;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

import static com.ledangaravi.slink.AuthenticatorActivity.dynamoDBMapper;
import static com.ledangaravi.slink.IntroActivity.username;
import static com.ledangaravi.slink.MainActivity.myWorkouts;

public class EnjoyActivity extends AppCompatActivity {
    private static final int BARCODE_READER_ACTIVITY_REQUEST = 1208;

    MqttHelper mqttHelper;

    //public static boolean defaultWod = true;

    public static String deviceID = "defaultDevice";
    public static String wodName = "Random WOD";


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_enjoy);

        ImageView imageView = (ImageView) findViewById(R.id.enjoy_imageView);
        TextView textView = (TextView) findViewById(R.id.enjoy_textView);
        Button button = (Button) findViewById(R.id.enjoy_button);

        imageView.setVisibility(View.INVISIBLE);
        textView.setVisibility(View.INVISIBLE);
        button.setVisibility(View.INVISIBLE);

        mqttHelper = new MqttHelper(getApplicationContext());
        mqttHelper.setCallback(new MqttCallbackExtended() {
            @Override
            public void connectComplete(boolean reconnect, String serverURI) {
                //mqttHelper.subscribe();
            }

            @Override
            public void connectionLost(Throwable cause) {
                Toast.makeText(getApplicationContext(), R.string.mqtt_toast_disconnected, Toast.LENGTH_SHORT).show();
            }

            @Override
            public void messageArrived(String topic, MqttMessage message) throws Exception {
                //Toast.makeText(getApplicationContext(),message.toString(), Toast.LENGTH_SHORT).show();
            }

            @Override
            public void deliveryComplete(IMqttDeliveryToken token) {

            }
        });


        Intent launchIntent = BarcodeReaderActivity.getLaunchIntent(this, true, false);
        startActivityForResult(launchIntent, BARCODE_READER_ACTIVITY_REQUEST);

    }

    public void submitWOD(){
        new Thread(new Runnable() {
            @Override
            public void run() {
                WODDO wodItem = dynamoDBMapper.load(WODDO.class,"slink", "Demo");

                final DEVICESDO devicesItem = new DEVICESDO();

                devicesItem.setDeviceID(deviceID);
                devicesItem.setUName(username);
                devicesItem.setWODName(wodItem.getWODName());
                devicesItem.setExList(wodItem.getExList());
                devicesItem.setRepList(wodItem.getRepList());
                devicesItem.setWList(wodItem.getWList());

                dynamoDBMapper.save(devicesItem);

                List<String> exL =  wodItem.getExList();
                List<String> repL = wodItem.getRepList();
                List<String> wL = wodItem.getWList();


                ArrayList<String> exList = new ArrayList<>();
                ArrayList<String> repList = new ArrayList<>();
                ArrayList<String> wList = new ArrayList<>();
//todo finish
                for(int i = 0; i < exL.size(); i++){
                    exL.add(exList.get(i));
                }


                JSONObject json = new JSONObject();
                try {

                    json.put("device_ID", deviceID);
                    json.put("u_name", username);
                    json.put("WOD_name", wodItem.getWODName());
                    json.put("exList", wodItem.getExList());
                    json.put("repList",wodItem.getRepList());
                    json.put("wList",wodItem.getWList());

                } catch (JSONException e) {
                    Log.e("MYAPP", "unexpected JSON exception", e);
                    // Do something to recover ... or kill the app.
                }

                mqttHelper.publishTopic = "slink/devices/"+deviceID;
                mqttHelper.payload = json;
                mqttHelper.publish();

            }
        }).start();

    }

    public void backHome(View view){
        Intent intent = new Intent(this, MainActivity.class);
        startActivity(intent);
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        ImageView imageView = (ImageView) findViewById(R.id.enjoy_imageView);
        TextView textView = (TextView) findViewById(R.id.enjoy_textView);
        Button button = (Button) findViewById(R.id.enjoy_button);

        if (resultCode != Activity.RESULT_OK) {
            Toast.makeText(this, R.string.setup_scan_fail, Toast.LENGTH_SHORT).show();
            Intent intent = new Intent(this, MainActivity.class);
            startActivity(intent);
            return;
        }

        if (requestCode == BARCODE_READER_ACTIVITY_REQUEST && data != null) {
            Barcode barcode = data.getParcelableExtra(BarcodeReaderActivity.KEY_CAPTURED_BARCODE);
            deviceID = barcode.rawValue;

            imageView.setVisibility(View.VISIBLE);
            textView.setVisibility(View.VISIBLE);
            button.setVisibility(View.VISIBLE);

            if(barcode.rawValue.toLowerCase().contains("slink")){
                deviceID = barcode.rawValue;
                submitWOD();
            }else{
                Toast.makeText(this, R.string.invalid_qr, Toast.LENGTH_SHORT).show();
                Intent intent = new Intent(this, MainActivity.class);
                startActivity(intent);
            }
        }
    }
}
