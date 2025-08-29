package br.com.nhttp

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.io.BufferedWriter
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import java.security.SecureRandom
import java.security.cert.X509Certificate
import javax.net.ssl.*

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
            val headers = call.argument<HashMap<String, String>>("headers") ?: HashMap()
            val timeOut = call.argument<Int>("timeOut") ?: 60000
            val body = try { call.argument<String>("body") ?: "" } catch (e: Exception) { "" }
            sendRequest(url, method, headers, timeOut, body, result)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    @OptIn(DelicateCoroutinesApi::class)
    private fun sendRequest(url: String, method: String, headers: HashMap<String, String>, timeOut: Int, body: String, @NonNull result: Result) {
        GlobalScope.launch(Dispatchers.Default) {

        val trustAllCerts = arrayOf<TrustManager>(
            object : X509TrustManager {
                override fun getAcceptedIssuers(): Array<X509Certificate> = arrayOf()
                override fun checkClientTrusted(chain: Array<X509Certificate>?, authType: String?) {}
                override fun checkServerTrusted(chain: Array<X509Certificate>?, authType: String?) {}
            }
        )

        val sc = SSLContext.getInstance("SSL")
        sc.init(null, trustAllCerts, SecureRandom())

        HttpsURLConnection.setDefaultSSLSocketFactory(sc.socketFactory)
        HttpsURLConnection.setDefaultHostnameVerifier { _, _ -> true }

        val conn = URL(url).openConnection() as HttpURLConnection
            try {
                conn.requestMethod = method
                headers.entries.forEach {
                    conn.setRequestProperty(it.key, it.value)
                }
                conn.readTimeout = timeOut
                conn.connectTimeout = timeOut
                conn.doInput = true

                if (mutableListOf("POST", "PUT").contains(method)) {
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
                    response["body"] = conn.inputStream.readBytes()
                } catch (e: Exception){
                    response["body"] = conn.errorStream.readBytes()
                }

                launch(Dispatchers.Main) {
                    result.success(response)
                }

            } catch (e: Exception) {
                launch(Dispatchers.Main) {
                    result.error("${e.message}", e.localizedMessage, null)
                }
            } finally {
                conn.disconnect();
            }
        }
    }
}
