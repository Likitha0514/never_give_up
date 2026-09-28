package com.example.never_give_up

import android.content.ContentValues
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "never_give_up/downloads"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "saveToDownloads") {
                try {
                    val bytes = call.argument<ByteArray>("bytes")
                    val fileName = call.argument<String>("fileName")
                    val mimeType = call.argument<String>("mimeType")

                    if (bytes == null || fileName == null || mimeType == null) {
                        result.error(
                            "INVALID_ARGUMENTS",
                            "Missing file data",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    val values = ContentValues().apply {
                        put(
                            MediaStore.Downloads.DISPLAY_NAME,
                            fileName
                        )
                        put(
                            MediaStore.Downloads.MIME_TYPE,
                            mimeType
                        )
                        put(
                            MediaStore.Downloads.RELATIVE_PATH,
                            "Download"
                        )
                    }

                    val uri = contentResolver.insert(
                        MediaStore.Downloads.EXTERNAL_CONTENT_URI,
                        values
                    )

                    if (uri == null) {
                        result.error(
                            "SAVE_FAILED",
                            "Could not create download file",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    contentResolver.openOutputStream(uri)?.use { output ->
                        output.write(bytes)
                    }

                    result.success(true)

                } catch (e: Exception) {
                    result.error(
                        "SAVE_FAILED",
                        e.message,
                        null
                    )
                }
            } else {
                result.notImplemented()
            }
        }
    }
}