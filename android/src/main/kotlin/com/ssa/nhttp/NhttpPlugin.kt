package com.ssa.nhttp

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.BufferedWriter
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import org.jetbrains.anko.doAsync
import org.jetbrains.anko.uiThread

class NhttpPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "nhttp")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "sendRequest") {
            val url = call.argument<String>("url")!!
            val method = call.argument<String>("method")!!
            val headers = call.argument<HashMap<String, Any>>("headers") ?: HashMap()
            val timeOut = call.argument<Int>("timeOut") ?: 60000
            val body = call.argument<String>("body") ?: ""
            sendRequest(url, method, headers, timeOut, body, result)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun sendRequest(url: String, method: String, headers: HashMap<String, Any>, timeOut: Int, body: String, @NonNull result: Result) {
        doAsync {
            val conn = URL(url).openConnection() as HttpURLConnection
            try {
                conn.requestMethod = method
                headers.entries.forEach {
                    conn.setRequestProperty(it.key, it.value as String)
                }
                conn.readTimeout = timeOut
                conn.connectTimeout = timeOut

                if (mutableListOf("POST", "PUT").contains(method)) {
                    conn.doInput = true
                    conn.doOutput = true

                    val outputStream = conn.outputStream
                    val writer = BufferedWriter(OutputStreamWriter(outputStream, "UTF-8"))
                    writer.write(body)
                    writer.flush()
                    writer.close()
                    outputStream.close()
                }

                conn.connect()

                val response = HashMap<String, Any>()
                response["statusCode"] = conn.responseCode
                try {
                    response["body"] = conn.inputStream.bufferedReader().use { it.readText() }
                } catch (e: Exception){
                    response["body"] = conn.errorStream.bufferedReader().use { it.readText() }
                }

                uiThread {
                    result.success(response)
                }

            } catch (e: Exception) {
                uiThread {
                    result.error(e.message, e.localizedMessage, null)
                }
            } finally {
                conn.disconnect();
            }
        }
    }
}
