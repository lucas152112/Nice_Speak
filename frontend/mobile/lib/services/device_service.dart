// services/device_service.dart
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  String? _deviceId;
  bool _isInitialized = false;

  /// 取得設備唯一 ID
  Future<String> getDeviceId() async {
    if (_deviceId != null && _isInitialized) {
      return _deviceId!;
    }

    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId = '';

    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = _generateDeviceId(
          androidInfo.id,
          androidInfo.model,
          androidInfo.brand,
        );
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = _generateDeviceId(
          iosInfo.identifierForVendor ?? '',
          iosInfo.name,
          iosInfo.model,
        );
      } else if (kIsWeb) {
        // Web 平台使用瀏覽器指紋
        deviceId = await _getWebFingerprint();
      }
    } catch (e) {
      // 如果無法取得設備資訊，產生隨機 ID
      deviceId = _generateFallbackId();
    }

    _deviceId = deviceId;
    _isInitialized = true;
    return deviceId;
  }

  /// 產生設備指紋
  String _generateDeviceId(String id, String model, String brand) {
    final input = '$id:$model:$brand';
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 32);
  }

  /// Web 指紋
  Future<String> _getWebFingerprint() async {
    // 簡化版 Web 指紋
    final input = '${DateTime.now().millisecondsSinceEpoch}';
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 32);
  }

  /// 產生備用 ID
  String _generateFallbackId() {
    final bytes = utf8.encode('${DateTime.now().millisecondsSinceEpoch}:fallback');
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 32);
  }

  /// 檢查設備狀態
  Future<DeviceStatus> checkDeviceStatus(String deviceId) async {
    // TODO: 呼叫後端 API 檢查設備狀態
    // GET /api/v1/devices/{deviceId}/status
    try {
      // 模擬 API 回應
      return DeviceStatus(
        deviceId: deviceId,
        hasUsedFreeTrial: false,
        isBanned: false,
      );
    } catch (e) {
      return DeviceStatus(
        deviceId: deviceId,
        hasUsedFreeTrial: false,
        isBanned: false,
        error: e.toString(),
      );
    }
  }
}

/// 設備狀態
class DeviceStatus {
  final String deviceId;
  final bool hasUsedFreeTrial;
  final bool isBanned;
  final String? error;

  DeviceStatus({
    required this.deviceId,
    required this.hasUsedFreeTrial,
    required this.isBanned,
    this.error,
  });

  bool get canUseFreeTrial => !hasUsedFreeTrial && !isBanned;
}

/// 設備註冊請求
class DeviceRegistration {
  final String deviceId;
  final String platform; // android, ios, web
  final String? fcmToken; // Firebase Cloud Messaging Token

  DeviceRegistration({
    required this.deviceId,
    required this.platform,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        'platform': platform,
        'fcm_token': fcmToken,
      };
}

/// 設備綁定服務
class DeviceBindingService {
  static final DeviceBindingService _instance = DeviceBindingService._internal();
  factory DeviceBindingService() => _instance;
  DeviceBindingService._internal();

  final DeviceService _deviceService = DeviceService();

  /// 初始化設備綁定
  Future<DeviceBindingResult> initialize() async {
    try {
      final deviceId = await _deviceService.getDeviceId();
      final status = await _deviceService.checkDeviceStatus(deviceId);

      return DeviceBindingResult(
        success: true,
        deviceId: deviceId,
        status: status,
      );
    } catch (e) {
      return DeviceBindingResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// 標記設備已使用免費試用
  Future<bool> markFreeTrialUsed(String deviceId) async {
    // TODO: 呼叫後端 API
    // POST /api/v1/devices/{deviceId}/mark-trial-used
    return true;
  }

  /// 檢查是否可以免費試用
  Future<bool> canUseFreeTrial() async {
    final deviceId = await _deviceService.getDeviceId();
    final status = await _deviceService.checkDeviceStatus(deviceId);
    return status.canUseFreeTrial;
  }
}

/// 設備綁定結果
class DeviceBindingResult {
  final bool success;
  final String? deviceId;
  final DeviceStatus? status;
  final String? error;

  DeviceBindingResult({
    required this.success,
    this.deviceId,
    this.status,
    this.error,
  });
}
