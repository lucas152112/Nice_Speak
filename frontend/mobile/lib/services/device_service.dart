// services/device_service.dart
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        deviceId = await _getWebFingerprint();
      }
    } catch (e) {
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

  /// 取得本地初次使用時間
  Future<DateTime?> getFirstUseDate() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('first_use_timestamp');
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  /// 設定初次使用時間
  Future<void> setFirstUseDate() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('first_use_timestamp', now);
  }

  /// 檢查設備狀態
  Future<DeviceStatus> checkDeviceStatus(String deviceId) async {
    try {
      // TODO: 呼叫後端 API 檢查設備狀態
      return DeviceStatus(
        deviceId: deviceId,
        hasUsedFreeTrial: false,
        isBanned: false,
        firstUsedAt: null,
        trialExpiredAt: null,
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

  /// 檢查是否可以免費試用 (含時間邏輯)
  Future<FreeTrialResult> checkFreeTrialStatus() async {
    final deviceId = await getDeviceId();
    final localFirstUse = await getFirstUseDate();
    
    // 如果本地沒有初次使用時間，寫入並允許使用
    if (localFirstUse == null) {
      await setFirstUseDate();
      return FreeTrialResult(
        canUse: true,
        reason: FreeTrialReason.firstTime,
        daysRemaining: 3,
      );
    }

    // 檢查後端設備狀態
    final status = await checkDeviceStatus(deviceId);
    
    if (status.isBanned) {
      return FreeTrialResult(
        canUse: false,
        reason: FreeTrialReason.banned,
        daysRemaining: 0,
      );
    }

    if (status.hasUsedFreeTrial) {
      return FreeTrialResult(
        canUse: false,
        reason: FreeTrialReason.alreadyUsed,
        daysRemaining: 0,
      );
    }

    // 計算剩餘天數
    final trialEndDate = status.trialExpiredAt ?? localFirstUse.add(const Duration(days: 3));
    final now = DateTime.now();
    final daysRemaining = trialEndDate.difference(now).inDays;

    if (daysRemaining <= 0) {
      return FreeTrialResult(
        canUse: false,
        reason: FreeTrialReason.expired,
        daysRemaining: 0,
      );
    }

    return FreeTrialResult(
      canUse: true,
      reason: FreeTrialReason.active,
      daysRemaining: daysRemaining,
    );
  }

  /// 標記設備已使用免費試用
  Future<bool> markFreeTrialUsed() async {
    final deviceId = await getDeviceId();
    // TODO: 呼叫後端 API
    return true;
  }
}

/// 設備狀態
class DeviceStatus {
  final String deviceId;
  final bool hasUsedFreeTrial;
  final bool isBanned;
  final DateTime? firstUsedAt;
  final DateTime? trialExpiredAt;
  final String? error;

  DeviceStatus({
    required this.deviceId,
    required this.hasUsedFreeTrial,
    required this.isBanned,
    this.firstUsedAt,
    this.trialExpiredAt,
    this.error,
  });

  bool get canUseFreeTrial => !hasUsedFreeTrial && !isBanned;
}

/// 免費試用結果
class FreeTrialResult {
  final bool canUse;
  final FreeTrialReason reason;
  final int daysRemaining;

  FreeTrialResult({
    required this.canUse,
    required this.reason,
    required this.daysRemaining,
  });
}

/// 免費試用原因
enum FreeTrialReason {
  firstTime,      // 初次使用
  active,         // 試用中
  alreadyUsed,    // 已使用過
  expired,        // 已過期
  banned,         // 被封禁
}
