import Foundation
import Sentry

enum Telemetry {
    static func start() {
        guard
            let dsn = Bundle.main.object(forInfoDictionaryKey: "SentryDSN") as? String,
            !dsn.isEmpty
        else { return }

        SentrySDK.start { options in
            options.dsn = dsn
            options.enableLogs = true
            options.sendDefaultPii = false
            options.tracesSampleRate = 0
            options.enableAutoSessionTracking = false
            options.enableAppHangTracking = false
            options.enableWatchdogTerminationTracking = false
            options.enableCaptureFailedRequests = false
            options.attachScreenshot = false
            options.attachViewHierarchy = false
            options.maxBreadcrumbs = 0
        }
    }

    static func log(_ event: String) {
        guard SentrySDK.isEnabled else { return }
        SentrySDK.logger.info(event, attributes: [
            "app.variant": "ios",
            "data.location": "on_device",
        ])
    }
}
