import Flutter
import UIKit
import home_widget
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60 * 15))

    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }

    if #available(iOS 17, *) {
      HomeWidgetBackgroundWorker.setPluginRegistrantCallback { registry in
        GeneratedPluginRegistrant.register(with: registry)
      }
    }

    if #available(iOS 13, *) {
      WorkmanagerPlugin.registerPeriodicTask(
        withIdentifier: "pie_widget_refresh_task",
        frequency: NSNumber(value: 20 * 60)
      )
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
