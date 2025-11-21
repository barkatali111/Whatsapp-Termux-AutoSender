package com.whatsapp

import android.app.Service
import android.content.Intent
import android.os.IBinder

class MessageService : Service() {

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {

        val receiver = intent?.getStringExtra("RECEIVER")
        val message = intent?.getStringExtra("MESSAGE")

        if (!receiver.isNullOrEmpty() && !message.isNullOrEmpty()) {
            BarkatooChat.sendMessage(receiver, message)
        }

        return START_NOT_STICKY
    }
}
