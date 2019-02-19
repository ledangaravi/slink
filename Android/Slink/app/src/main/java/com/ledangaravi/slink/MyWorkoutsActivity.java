package com.ledangaravi.slink;

import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.amazonaws.models.nosql.WODDO;




public class MyWorkoutsActivity extends AppCompatActivity {



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_my_workouts);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                Snackbar.make(view, "Replace with your own action", Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        });
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);



        //getDefaultWOD();
        generateList();

    }

    void generateList(){
        LinearLayout linearLayout = (LinearLayout) findViewById(R.id.my_workouts_linear_layout);

        for (int i = 0; i < MainActivity.myWorkouts.size(); i++){
            WODDO current = MainActivity.myWorkouts.get(i);
            TextView textView = new TextView(this);
            textView.setText(current.getWODName());
            textView.setId(View.generateViewId());
            textView.setTextAppearance(this, R.style.my_workout_items);
            linearLayout.addView(textView);
        }

    }



}
