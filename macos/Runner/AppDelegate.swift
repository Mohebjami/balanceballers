import Cocoa
import FlutterMacOS

@NSApplicationMain
@main
 
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
}
