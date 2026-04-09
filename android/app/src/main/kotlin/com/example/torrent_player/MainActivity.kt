package com.example.torrent_player

import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    private val intentChannel = "torrent_player/intent"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, intentChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "copyContentUri" -> {
                        val uriString = call.argument<String>("uri")
                        if (uriString == null) {
                            result.error("INVALID_URI", "URI argument is null", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val uri = Uri.parse(uriString)
                            val inputStream = contentResolver.openInputStream(uri)
                            if (inputStream == null) {
                                result.error("CANNOT_READ", "Cannot open input stream for $uriString", null)
                                return@setMethodCallHandler
                            }
                            val tempFile = File(cacheDir, "torrent_${System.currentTimeMillis()}.torrent")
                            tempFile.outputStream().use { output -> inputStream.copyTo(output) }
                            inputStream.close()
                            result.success(tempFile.absolutePath)
                        } catch (e: Exception) {
                            result.error("COPY_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
