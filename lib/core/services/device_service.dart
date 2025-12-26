import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Returns a unique ID for the current device.
  /// On Android: androidId
  /// On iOS: identifierForVendor
  /// On Web/Desktop: A fallback string
  Future<String> getDeviceId() async {
    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        return 'web-${webInfo.userAgent.hashCode}';
      }

      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          final androidInfo = await _deviceInfo.androidInfo;
          return androidInfo.id; // Unique ID for the device
        case TargetPlatform.iOS:
          final iosInfo = await _deviceInfo.iosInfo;
          return iosInfo.identifierForVendor ?? 'unknown-ios-device';
        case TargetPlatform.windows:
          final windowsInfo = await _deviceInfo.windowsInfo;
          return windowsInfo.deviceId;
        default:
          return 'unknown-platform-device';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting device ID: $e');
      }
      return 'error-device-id';
    }
  }

  /// Returns a human-readable device model name.
  Future<String> getDeviceModel() async {
    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        return '${webInfo.browserName.name} on ${webInfo.platform}';
      }

      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          final androidInfo = await _deviceInfo.androidInfo;
          return '${androidInfo.brand} ${androidInfo.model}';
        case TargetPlatform.iOS:
          final iosInfo = await _deviceInfo.iosInfo;
          return '${iosInfo.name} ${iosInfo.model}';
        case TargetPlatform.windows:
          final windowsInfo = await _deviceInfo.windowsInfo;
          return 'Windows PC (${windowsInfo.computerName})';
        default:
          return 'Unknown Device';
      }
    } catch (e) {
      return 'Generic Device';
    }
  }
}
