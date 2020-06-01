import AppKit

guard let bundle = Bundle(identifier: "sexy.kofi.multi") else {
    Error.window(message: "Multi.app is not installed — try installing it first.")
    exit(1)
}

guard let url = bundle.url(forResource: "Runner", withExtension: nil) else {
    Error.window(message: "Multi.app is misconfigured or broken — try re-installing it.")
    exit(2)
}
