//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import app_settings
import cloud_firestore
import firebase_auth
import firebase_core
import geolocator_apple
import package_info_plus

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  AppSettingsPlugin.register(with: registry.registrar(forPlugin: "AppSettingsPlugin"))
  FLTFirebaseFirestorePlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseFirestorePlugin"))
  FLTFirebaseAuthPlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseAuthPlugin"))
  FLTFirebaseCorePlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseCorePlugin"))
  GeolocatorPlugin.register(with: registry.registrar(forPlugin: "GeolocatorPlugin"))
  FPPPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FPPPackageInfoPlusPlugin"))
}
