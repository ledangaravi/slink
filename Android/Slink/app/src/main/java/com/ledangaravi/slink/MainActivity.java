package com.ledangaravi.slink;

import android.app.Activity;
import android.content.Intent;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;


import com.amazonaws.mobile.auth.core.IdentityManager;
import com.amazonaws.mobileconnectors.dynamodbv2.dynamodbmapper.DynamoDBQueryExpression;
import com.amazonaws.mobileconnectors.dynamodbv2.dynamodbmapper.PaginatedList;
import com.amazonaws.models.nosql.WODDO;

import static com.ledangaravi.slink.AuthenticatorActivity.dynamoDBMapper;
import static com.ledangaravi.slink.IntroActivity.username;


public class MainActivity extends AppCompatActivity {


    public static PaginatedList<WODDO> myWorkouts;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        int numberOfWorkouts = 3;
        String welcomeMessage = getResources().getString(R.string.main_welcome_1) + " "
                + username + "!";
                //+ getResources().getString(R.string.main_welcome_2) + " "
                //+ Integer.toString(numberOfWorkouts) + " "
                //+ getResources().getString(R.string.main_welcome_3);
        TextView textView = findViewById(R.id.textView_main_welcome);
        textView.setText(welcomeMessage);

        getDefaultWOD();

    }

    public void randomWOD(View view) {
        // Do something in response to button
        Intent intent = new Intent(this, EnjoyActivity.class);
        startActivity(intent);
    }
    public void myWOD(View view) {
        // Do something in response to button
        //Snackbar.make(view, "Coming soon", Snackbar.LENGTH_LONG).setAction("Action", null).show();

        Intent intent = new Intent(this, MyWorkoutsActivity.class);
        startActivity(intent);
    }
    public void stats(View view) {
        // Do something in response to button
        //Snackbar.make(view, "Coming soon", Snackbar.LENGTH_LONG).setAction("Action", null).show();
        Intent intent = new Intent(this, TestActivity.class);
        startActivity(intent);
    }

    public void startSetup(View view) {
        // Do something in response to button
        Intent intent = new Intent(this, SetupActivity.class);
        startActivity(intent);
    }

    public void signOut(View view) {
        Log.d("LOG_TAG", "User Signed Out button pressed");
        IdentityManager.getDefaultIdentityManager().signOut();
    }


    public void startHistory(View view){
        Intent intent = new Intent(this, HistoryActivity.class);
        startActivity(intent);
    }



    void getDefaultWOD(){
        //hash key  = partition key
        //range key = sort key
        new Thread(new Runnable() {
            @Override
            public void run() {
                WODDO wodItem = new WODDO();
                wodItem.setUName("slink");
                //wodItem.setWODName("m");


                DynamoDBQueryExpression queryExpression = new DynamoDBQueryExpression()
                        .withHashKeyValues(wodItem)
                        .withConsistentRead(false);

                myWorkouts = dynamoDBMapper.query(WODDO.class, queryExpression);


                if (myWorkouts.isEmpty()) {
                    // There were no items matching your query.
                    Log.e("Query result: ", "nothing :(");
                    //todo deal with it
                }
            }
        }).start();
    }

}
