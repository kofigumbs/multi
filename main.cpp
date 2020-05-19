#include <iostream>
#include "webview/webview.h"

// Copied from Safari, required for Slack
static const std::string user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Safari/605.1.15";

int main() {
  webview::webview w(true, nullptr);
  w.set_title("Chat");
  w.set_size(1440, 1600, WEBVIEW_HINT_NONE);
  w.set_user_agent(user_agent);
	w.navigate("https://app.slack.com/client");
	w.run();
  return 0;
}
