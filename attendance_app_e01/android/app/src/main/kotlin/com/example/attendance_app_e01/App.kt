package com.example.attendance_app_e01

import android.app.Application
import android.content.Context
import com.facebook.stetho.Stetho
import io.flutter.app.FlutterApplication

class App  : FlutterApplication(){
    companion object {
        lateinit var instance: Application
    }

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
    }


    override fun onCreate() {
        super.onCreate()
        instance = this
        Stetho.initializeWithDefaults(this)
    }
}