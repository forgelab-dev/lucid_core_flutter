#ifndef FLUTTER_PLUGIN_LUCID_CORE_FLUTTER_PLUGIN_H_
#define FLUTTER_PLUGIN_LUCID_CORE_FLUTTER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace lucid_core_flutter {

class LucidCoreFlutterPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  LucidCoreFlutterPlugin();

  virtual ~LucidCoreFlutterPlugin();

  // Disallow copy and assign.
  LucidCoreFlutterPlugin(const LucidCoreFlutterPlugin&) = delete;
  LucidCoreFlutterPlugin& operator=(const LucidCoreFlutterPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace lucid_core_flutter

#endif  // FLUTTER_PLUGIN_LUCID_CORE_FLUTTER_PLUGIN_H_
