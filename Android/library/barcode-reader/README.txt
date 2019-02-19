https://github.com/avaneeshkumarmaurya/Barcode-Reader

import module, add dependency  in app's build.gradle:


dependencies {
    // google vision gradle
    implementation 'com.google.android.gms:play-services-vision:15.0.2'
}




launch activity with:


Intent launchIntent = BarcodeReaderActivity.getLaunchIntent(this, true, false);
startActivityForResult(launchIntent, BARCODE_READER_ACTIVITY_REQUEST);


protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (resultCode != Activity.RESULT_OK) {
            Toast.makeText(this, "error in  scanning", Toast.LENGTH_SHORT).show();
            return;
        }

        if (requestCode == BARCODE_READER_ACTIVITY_REQUEST && data != null) {
            Barcode barcode = data.getParcelableExtra(BarcodeReaderActivity.KEY_CAPTURED_BARCODE);
            Toast.makeText(this, barcode.rawValue, Toast.LENGTH_SHORT).show();
        }

    }