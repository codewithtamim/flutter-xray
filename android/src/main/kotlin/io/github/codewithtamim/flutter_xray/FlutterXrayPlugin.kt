package io.github.codewithtamim.flutter_xray

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import libXray.DialerController
import libXray.LibXray
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

/** FlutterXrayPlugin */
class FlutterXrayPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var protectChannel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_xray")
        channel.setMethodCallHandler(this)

        protectChannel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            "flutter_xray/protect",
        )
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "setTunFd" -> {
                val fd = call.argument<Int>("fd") ?: -1
                LibXray.setTunFd(fd)
                result.success(null)
            }

            "runXray" -> {
                val base64Request = call.argument<String>("base64Request") ?: ""
                result.success(LibXray.runXray(base64Request))
            }

            "runXrayFromJSON" -> {
                val base64Request = call.argument<String>("base64Request") ?: ""
                result.success(LibXray.runXrayFromJSON(base64Request))
            }

            "stopXray" -> {
                result.success(LibXray.stopXray())
            }

            "getXrayState" -> {
                result.success(LibXray.getXrayState())
            }

            "xrayVersion" -> {
                result.success(LibXray.xrayVersion())
            }

            "testXray" -> {
                val base64Request = call.argument<String>("base64Request") ?: ""
                result.success(LibXray.testXray(base64Request))
            }

            "ping" -> {
                val base64Request = call.argument<String>("base64Request") ?: ""
                result.success(LibXray.ping(base64Request))
            }

            "queryStats" -> {
                val server = call.argument<String>("server") ?: ""
                result.success(LibXray.queryStats(server))
            }

            "countGeoData" -> {
                val base64Request = call.argument<String>("base64Request") ?: ""
                result.success(LibXray.countGeoData(base64Request))
            }

            "readGeoFiles" -> {
                val base64XrayConfig = call.argument<String>("base64XrayConfig") ?: ""
                result.success(LibXray.readGeoFiles(base64XrayConfig))
            }

            "buildMphCache" -> {
                val base64Request = call.argument<String>("base64Request") ?: ""
                result.success(LibXray.buildMphCache(base64Request))
            }

            "getFreePorts" -> {
                val count = call.argument<Int>("count") ?: 0
                result.success(LibXray.getFreePorts(count.toLong()))
            }

            "convertShareLinksToXrayJson" -> {
                val base64Links = call.argument<String>("base64Links") ?: ""
                result.success(LibXray.convertShareLinksToXrayJson(base64Links))
            }

            "convertXrayJsonToShareLinks" -> {
                val base64XrayJson = call.argument<String>("base64XrayJson") ?: ""
                result.success(LibXray.convertXrayJsonToShareLinks(base64XrayJson))
            }

            "registerDialerController" -> {
                LibXray.registerDialerController(createDialerController())
                result.success(null)
            }

            "registerListenerController" -> {
                LibXray.registerListenerController(createDialerController())
                result.success(null)
            }

            "initAndroidDns" -> {
                val server = call.argument<String>("server") ?: ""
                LibXray.initDns(createDialerController(), server)
                result.success(null)
            }

            "resetAndroidDns" -> {
                LibXray.resetDns()
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        protectChannel.setMethodCallHandler(null)
    }

    private fun createDialerController(): DialerController {
        return object : DialerController {
            override fun protectFd(fd: Long): Boolean {
                val latch = CountDownLatch(1)
                var protectResult = false

                protectChannel.invokeMethod(
                    "protectFd",
                    fd.toInt(),
                    object : Result {
                        override fun success(r: Any?) {
                            protectResult = r as? Boolean ?: false
                            latch.countDown()
                        }

                        override fun error(
                            errorCode: String,
                            errorMessage: String?,
                            errorDetails: Any?,
                        ) {
                            latch.countDown()
                        }

                        override fun notImplemented() {
                            latch.countDown()
                        }
                    },
                )

                try {
                    latch.await(5, TimeUnit.SECONDS)
                } catch (_: InterruptedException) {
                    Thread.currentThread().interrupt()
                }

                return protectResult
            }
        }
    }
}
