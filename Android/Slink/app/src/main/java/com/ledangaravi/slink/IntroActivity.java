//tutorial activity
package com.ledangaravi.slink;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import android.widget.ImageView;
import android.widget.TextView;

import com.amazonaws.mobile.config.AWSConfiguration;
import com.amazonaws.mobileconnectors.cognitoidentityprovider.CognitoUserPool;

public class IntroActivity extends AppCompatActivity {
    public static String username;

    /**
     * The {@link android.support.v4.view.PagerAdapter} that will provide
     * fragments for each of the sections. We use a
     * {@link FragmentPagerAdapter} derivative, which will keep every
     * loaded fragment in memory. If this becomes too memory intensive, it
     * may be best to switch to a
     * {@link android.support.v4.app.FragmentStatePagerAdapter}.
     */
    private SectionsPagerAdapter mSectionsPagerAdapter;

    /**
     * The {@link ViewPager} that will host the section contents.
     */
    private ViewPager mViewPager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);


        //check the last logged in user
        SharedPreferences sharedPref = this.getPreferences(Context.MODE_PRIVATE);
        String defaultValue = "";
        String lastUser = sharedPref.getString(getString(R.string.user_KEY), defaultValue);

        //get the current user
        CognitoUserPool userpool = new CognitoUserPool(IntroActivity.this, new AWSConfiguration(IntroActivity.this));
        username = userpool.getCurrentUser().getUserId();

        if(username.equals(lastUser)){
            //if same user as last time don't display tutorial, move on to main screen
            Intent intent = new Intent(this, MainActivity.class);
            startActivity(intent);
        }else{
            //updated the stored username
            SharedPreferences.Editor editor = sharedPref.edit();
            editor.putString(getString(R.string.user_KEY), username);
            editor.apply();
        }

        setContentView(R.layout.activity_intro);

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayShowHomeEnabled(false);
        getSupportActionBar().setDisplayShowTitleEnabled(false);


        // Create the adapter that will return a fragment for each of the three
        // primary sections of the activity.
        mSectionsPagerAdapter = new SectionsPagerAdapter(getSupportFragmentManager());

        // Set up the ViewPager with the sections adapter.
        mViewPager = (ViewPager) findViewById(R.id.container);
        mViewPager.setAdapter(mSectionsPagerAdapter);

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                //Snackbar.make(view, "Replace with your own action", Snackbar.LENGTH_LONG).setAction("Action", null).show();
                Intent intent = new Intent(getApplicationContext(), MainActivity.class);
                startActivity(intent);
            }
        });



    }


    /*
    removed because no action bar is displayed

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_intro, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }*/

    /**
     * A placeholder fragment containing a simple view.
     */
    public static class PlaceholderFragment extends Fragment {
        /**
         * The fragment argument representing the section number for this
         * fragment.
         */
        private static final String ARG_SECTION_NUMBER = "section_number";

        public PlaceholderFragment() {
        }

        /**
         * Returns a new instance of this fragment for the given section
         * number.
         */
        public static PlaceholderFragment newInstance(int sectionNumber) {
            PlaceholderFragment fragment = new PlaceholderFragment();
            Bundle args = new Bundle();
            args.putInt(ARG_SECTION_NUMBER, sectionNumber);
            fragment.setArguments(args);
            return fragment;
        }

        @Override
        public View onCreateView(LayoutInflater inflater, ViewGroup container,
                                 Bundle savedInstanceState) {
            View rootView = inflater.inflate(R.layout.fragment_intro, container, false);

            ImageView checkList = (ImageView) rootView.findViewById((R.id.intro_2_checklist));
            ImageView fitnessIcon = (ImageView) rootView.findViewById(R.id.intro_1_fitness_icon);
            ImageView arrowRight = (ImageView) rootView.findViewById(R.id.intro_arrow_right);
            ImageView arrowLeft = (ImageView) rootView.findViewById(R.id.intro_arrow_left);

            TextView intro1text = (TextView) rootView.findViewById(R.id.intro1_text);
            TextView intro2text = (TextView) rootView.findViewById(R.id.intro2_text);
            TextView intro3title = (TextView) rootView.findViewById(R.id.intro3_title);
            TextView intro3text = (TextView) rootView.findViewById(R.id.intro3_text);



            switch (getArguments().getInt(ARG_SECTION_NUMBER)){
                case 1:
                    checkList.setVisibility(View.INVISIBLE);
                    arrowLeft.setVisibility(View.INVISIBLE);
                    intro2text.setVisibility(View.INVISIBLE);
                    intro3title.setVisibility(View.INVISIBLE);
                    intro3text.setVisibility(View.INVISIBLE);
                    break;
                case 2:
                    fitnessIcon.setVisibility(View.INVISIBLE);
                    intro1text.setVisibility(View.INVISIBLE);
                    intro3title.setVisibility(View.INVISIBLE);
                    intro3text.setVisibility(View.INVISIBLE);
                    break;

                case 3:
                    checkList.setVisibility(View.INVISIBLE);
                    fitnessIcon.setVisibility(View.INVISIBLE);
                    arrowRight.setVisibility(View.INVISIBLE);
                    intro1text.setVisibility(View.INVISIBLE);
                    intro2text.setVisibility(View.INVISIBLE);

                    break;
            }










            return rootView;
        }
    }

    /**
     * A {@link FragmentPagerAdapter} that returns a fragment corresponding to
     * one of the sections/tabs/pages.
     */
    public class SectionsPagerAdapter extends FragmentPagerAdapter {

        public SectionsPagerAdapter(FragmentManager fm) {
            super(fm);
        }

        @Override
        public Fragment getItem(int position) {
            // getItem is called to instantiate the fragment for the given page.
            // Return a PlaceholderFragment (defined as a static inner class below).
            return PlaceholderFragment.newInstance(position + 1);
        }

        @Override
        public int getCount() {
            // Show 3 total pages.
            return 3;
        }
    }
}
