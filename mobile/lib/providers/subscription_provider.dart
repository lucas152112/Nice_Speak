import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum SubscriptionPlan { free, premium }

class SubscriptionProvider with ChangeNotifier {
  SubscriptionPlan _plan = SubscriptionPlan.free;
  DateTime? _expiryDate;
  bool _isLoading = false;

  SubscriptionPlan get plan => _plan;
  bool get isPremium => _plan == SubscriptionPlan.premium;
  DateTime? get expiryDate => _expiryDate;
  bool get isLoading => _isLoading;
  bool get isExpired => _expiryDate != null && DateTime.now().isAfter(_expiryDate!);

  Future<void> fetchSubscription() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // TODO: API call to fetch subscription status
      await Future.delayed(const Duration(milliseconds: 500));
      // Simulated response
      _plan = SubscriptionPlan.free;
    } catch (e) {
      debugPrint('Error fetching subscription: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> purchasePremium() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // TODO: API call to purchase premium
      await Future.delayed(const Duration(seconds: 2));
      _plan = SubscriptionPlan.premium;
      _expiryDate = DateTime.now().add(const Duration(days: 30));
    } catch (e) {
      debugPrint('Error purchasing premium: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelSubscription() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // TODO: API call to cancel subscription
      await Future.delayed(const Duration(seconds: 1));
      // Keep premium until expiry
    } catch (e) {
      debugPrint('Error canceling subscription: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String get formattedExpiryDate {
    if (_expiryDate == null) return '無';
    return DateFormat('yyyy/MM/dd').format(_expiryDate!);
  }
}
