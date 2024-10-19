package com.example.money_transfer;
import android.app.ActivityManager;
import android.content.Context;
import android.os.Build;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.money_transfer/clearData";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("clearAppData")) {
                        clearAppData();
                        result.success("App data cleared");
                    } else {
                        result.notImplemented();
                    }
                }
        );
    }

    private void clearAppData() {
        ActivityManager activityManager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            activityManager.clearApplicationUserData(); // API level 19+
        } else {
            try {
                Runtime runtime = Runtime.getRuntime();
                runtime.exec("pm clear " + getPackageName());
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
