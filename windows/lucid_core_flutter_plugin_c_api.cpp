#include "include/lucid_core_flutter/lucid_core_flutter_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "lucid_core_flutter_plugin.h"

void LucidCoreFlutterPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  lucid_core_flutter::LucidCoreFlutterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
