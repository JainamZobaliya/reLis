//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <libwinmedia/libwinmedia_plugin.h>
#include <native_pdf_renderer/native_pdf_renderer_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  LibwinmediaPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("LibwinmediaPlugin"));
  NativePdfRendererPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("NativePdfRendererPlugin"));
}
