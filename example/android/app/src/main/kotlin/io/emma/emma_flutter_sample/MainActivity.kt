package io.emma.emma_flutter_sample

import android.view.ViewGroup
import android.view.ViewTreeObserver
import android.widget.FrameLayout
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.RenderMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "app/strip_margin"
    }

    private var lastStripActive: Boolean? = null
    private var notifyingFlutter = false
    private var methodChannel: MethodChannel? = null
    private var preDrawListener: ViewTreeObserver.OnPreDrawListener? = null
    private var trackedChild: android.view.View? = null

    // TextureView renders inside the normal View hierarchy, so OnPreDrawListener
    // can block its draw. SurfaceView renders to a separate layer and ignores it.
    override fun getRenderMode(): RenderMode = RenderMode.texture

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        val content = findViewById<FrameLayout>(android.R.id.content)
        methodChannel?.setMethodCallHandler { call, result ->
            if (call.method == "getInitialStripState") {
                val child = content.getChildAt(0)
                val margin = (child?.layoutParams as? ViewGroup.MarginLayoutParams)?.topMargin ?: 0
                result.success(margin > 0)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onStart() {
        super.onStart()
        val content = findViewById<FrameLayout>(android.R.id.content)
        content.post {
            val child = content.getChildAt(0) ?: return@post
            if (trackedChild === child) return@post
            trackedChild = child

            val listener = ViewTreeObserver.OnPreDrawListener {
                val margin = (child.layoutParams as? ViewGroup.MarginLayoutParams)?.topMargin ?: 0
                val stripActive = margin > 0

                if (stripActive != lastStripActive && !notifyingFlutter) {
                    notifyingFlutter = true
                    methodChannel?.invokeMethod(
                        "stripVisibility",
                        stripActive,
                        object : MethodChannel.Result {
                            override fun success(result: Any?) = onFlutterReady(stripActive, child)
                            override fun error(c: String, m: String?, d: Any?) = onFlutterReady(stripActive, child)
                            override fun notImplemented() = onFlutterReady(stripActive, child)
                        }
                    )
                }

                // Block this draw until Flutter has rendered the updated layout.
                // Returns true (allow draw) only when lastStripActive matches current state.
                stripActive == lastStripActive
            }
            preDrawListener = listener
            child.viewTreeObserver.addOnPreDrawListener(listener)
        }
    }

    private fun onFlutterReady(stripActive: Boolean, child: android.view.View) {
        lastStripActive = stripActive
        notifyingFlutter = false
        child.postInvalidate()
    }

    override fun onStop() {
        super.onStop()
        val listener = preDrawListener ?: return
        trackedChild?.viewTreeObserver?.removeOnPreDrawListener(listener)
        preDrawListener = null
        trackedChild = null
        lastStripActive = null
        notifyingFlutter = false
    }
}
