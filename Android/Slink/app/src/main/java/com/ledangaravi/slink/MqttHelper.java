package com.ledangaravi.slink;

import android.content.Context;
import android.util.Log;
import android.widget.Toast;

import org.eclipse.paho.android.service.MqttAndroidClient;
import org.eclipse.paho.client.mqttv3.IMqttActionListener;
import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;
import org.eclipse.paho.client.mqttv3.IMqttToken;
import org.eclipse.paho.client.mqttv3.MqttCallbackExtended;
import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;

class MqttHelper {
    MqttAndroidClient client;
    String clientId = MqttClient.generateClientId();
    String serverURL = "tcp://broker.mqttdashboard.com:1883";//"tcp://test.mosquitto.org:1883";
    String subscribeTopic = "slink/test";//"IC.embedded/TeamName/android";
    String publishTopic = "slink/test";//"IC.embedded/TeamName/android";
    JSONObject payload;

    MqttHelper(final Context context){
        client = new MqttAndroidClient(context, serverURL, clientId);
        client.setCallback(new MqttCallbackExtended() {
            @Override
            public void connectComplete(boolean reconnect, String serverURI) {
                subscribe();
            }

            @Override
            public void connectionLost(Throwable cause) {
                Toast.makeText(context, R.string.mqtt_toast_disconnected, Toast.LENGTH_SHORT).show();
            }

            @Override
            public void messageArrived(String topic, MqttMessage message) throws Exception {
                //Toast.makeText(context,message.toString(), Toast.LENGTH_SHORT).show();
            }

            @Override
            public void deliveryComplete(IMqttDeliveryToken token) {

            }
        });

        try {
            IMqttToken token = client.connect();
            token.setActionCallback(new IMqttActionListener() {
                @Override
                public void onSuccess(IMqttToken asyncActionToken) {
                    // We are connected
                    Log.d("mqtt", "onSuccess");
                    //Toast.makeText(context, R.string.mqtt_toast_connected, Toast.LENGTH_SHORT).show();
                }

                @Override
                public void onFailure(IMqttToken asyncActionToken, Throwable exception) {
                    // Something went wrong e.g. connection timeout or firewall problems
                    Log.d("mqtt", "onFailure");
                    Toast.makeText(context, R.string.mqtt_toast_connection_unavailable, Toast.LENGTH_SHORT).show();

                }
            });
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }

    void setCallback(MqttCallbackExtended callback) {
        client.setCallback(callback);
    }

    void subscribe(){
        int qos = 1;
        try {
            IMqttToken subToken = client.subscribe(subscribeTopic, qos);
            subToken.setActionCallback(new IMqttActionListener() {
                @Override
                public void onSuccess(IMqttToken asyncActionToken) {
                    // The message was published
                }

                @Override
                public void onFailure(IMqttToken asyncActionToken,
                                      Throwable exception) {
                    // The subscription could not be performed, maybe the user was not
                    // authorized to subscribe on the specified topic e.g. using wildcards

                }
            });
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }

    void publish(){
        byte[] encodedPayload = new byte[0];
        try {
            encodedPayload = payload.toString().getBytes("UTF-8");
            MqttMessage message = new MqttMessage(encodedPayload);
            client.publish(publishTopic, message);
        } catch (UnsupportedEncodingException | MqttException e) {
            e.printStackTrace();
        }
    }
}
