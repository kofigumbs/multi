import AppKit

guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "llc.gumbs.multi"),
      let frameworks = Bundle(url: appURL)?.privateFrameworksURL,
      let runtime = dlopen(frameworks.appendingPathComponent("libRuntime.dylib").path, RTLD_NOW),
      let runtimeMain = dlsym(runtime, "RuntimeMain") else {
    let alert = NSAlert()
    alert.messageText = "Cannot open Multi.app/Contents/Frameworks/libRuntime.dylib"
    alert.runModal()
    exit(1)
}

unsafeBitCast(runtimeMain, to: (@convention(c) () -> Void).self)()
