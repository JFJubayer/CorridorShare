import 'package:flutter/material.dart';
import '../models/package_model.dart';
import '../models/trip_model.dart';

enum AppRole { sender, traveler }

class UserProvider extends ChangeNotifier {
  AppRole _role = AppRole.sender;
  bool _isAuthenticated = false;
  String _phone = '';
  double _walletBalance = 12450.00;
  double _escrowLockedBalance = 1800.00;
  String _nidStatus = 'verified'; // 'unverified', 'pending', 'verified'
  final String _nidPhotoUrl = '';
  bool _isDarkMode = true;
  final String _userId = '11111111-1111-1111-1111-111111111111';

  // State Getters
  AppRole get role => _role;
  bool get isTraveler => _role == AppRole.traveler;
  bool get isAuthenticated => _isAuthenticated;
  String get phone => _phone;
  double get walletBalance => _walletBalance;
  double get escrowLockedBalance => _escrowLockedBalance;
  String get nidStatus => _nidStatus;
  String get nidPhotoUrl => _nidPhotoUrl;
  bool get isDarkMode => _isDarkMode;
  String get userId => _userId;

  // Mock Trips List matching Stitch Corridor Feed (Dhaka-Mymensingh N3 Corridor)
  final List<TripModel> _trips = [
    TripModel(
      id: 'trip-1',
      travelerId: 't-101',
      departureCity: 'Dhaka North (Uttara)',
      destinationCity: 'Mymensingh City Bypass',
      travelTime: 'Today 2:30 PM',
      weightCapacityKg: 12.0,
      status: 'Active',
      travelerName: 'Ahmed R.',
      travelerRating: '4.9 ★',
    ),
    TripModel(
      id: 'trip-2',
      travelerId: 't-102',
      departureCity: 'Gazipur Chaurasta',
      destinationCity: 'Trishal University Gate',
      travelTime: 'Today 5:00 PM',
      weightCapacityKg: 8.5,
      status: 'Scheduled',
      travelerName: 'Sara K.',
      travelerRating: '5.0 ★',
    ),
    TripModel(
      id: 'trip-3',
      travelerId: 't-103',
      departureCity: 'Dhaka Airport Road',
      destinationCity: 'Sherpur Town Corridor',
      travelTime: 'Tonight 8:00 PM',
      weightCapacityKg: 15.0,
      status: 'Scheduled',
      travelerName: 'Aminul Islam',
      travelerRating: '4.8 ★',
    ),
  ];

  // Mock Packages List
  final List<PackageModel> _packages = [
    PackageModel(
      id: 'CS-9821',
      senderId: 's-201',
      itemDescription: 'Urgent Legal Document Envelope',
      proposedReward: 250.0,
      isPremium: true,
      pickupLat: 23.822349,
      pickupLng: 90.414349,
      routeInfo: 'Dhaka North → Gazipur Bypass',
      eta: 'Today 4:00 PM',
      itemType: 'Legal Document (0.5kg)',
    ),
    PackageModel(
      id: 'CS-7742',
      senderId: 's-202',
      itemDescription: 'Laptop Power Adapter & Parts',
      proposedReward: 450.0,
      isPremium: false,
      pickupLat: 24.150000,
      pickupLng: 90.400000,
      routeInfo: 'Gazipur → Mymensingh',
      eta: 'Today 6:30 PM',
      itemType: 'Electronics Cargo (2.5kg)',
    ),
    PackageModel(
      id: 'CS-3109',
      senderId: 's-203',
      itemDescription: 'Fresh Bakery Confectionery Box',
      proposedReward: 350.0,
      isPremium: false,
      pickupLat: 24.500000,
      pickupLng: 90.410000,
      routeInfo: 'Mymensingh → Trishal Corridor',
      eta: 'Tomorrow Morning',
      itemType: 'Food Box (3.0kg)',
      isNearMiss: true,
      distanceFromCorridor: 520.0,
    ),
  ];

  // Activity Feed
  final List<String> _activityFeed = [
    "Ahmed R. matched on N3 Corridor (Gazipur Bypass)",
    "Escrow Safety Lock of ৳450 enforced for Package CS-7742",
    "Sara K. NID verification seal confirmed",
    "Package CS-9821 payout released via bKash upon OTP validation"
  ];

  List<TripModel> get trips => _trips;
  List<PackageModel> get packages => _packages;
  List<String> get activityFeed => _activityFeed;

  void toggleRole() {
    _role = _role == AppRole.sender ? AppRole.traveler : AppRole.sender;
    notifyListeners();
  }

  void setRole(AppRole newRole) {
    _role = newRole;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  bool login(String phoneInput) {
    if (phoneInput.isEmpty) return false;
    _phone = phoneInput;
    _isAuthenticated = true;
    _nidStatus = 'verified';
    notifyListeners();
    return true;
  }

  void logout() {
    _isAuthenticated = false;
    _phone = '';
    notifyListeners();
  }

  void topUpBkash(double amount) {
    _walletBalance += amount;
    _activityFeed.insert(0, "Top-Up: Added ৳${amount.toStringAsFixed(0)} via bKash Wallet");
    notifyListeners();
  }

  void topUpNagad(double amount) {
    _walletBalance += amount;
    _activityFeed.insert(0, "Top-Up: Added ৳${amount.toStringAsFixed(0)} via Nagad Wallet");
    notifyListeners();
  }

  bool deductWallet(double amount) {
    if (_walletBalance < amount) return false;
    _walletBalance -= amount;
    _escrowLockedBalance += amount;
    notifyListeners();
    return true;
  }

  void releaseEscrowPayout(double amount) {
    if (_escrowLockedBalance >= amount) {
      _escrowLockedBalance -= amount;
    }
    notifyListeners();
  }

  void addTrip({
    required String departure,
    required String destination,
    required String date,
    required double capacity,
  }) {
    final newTrip = TripModel(
      id: 'trip-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      travelerId: _userId,
      departureCity: departure,
      destinationCity: destination,
      travelTime: date,
      weightCapacityKg: capacity,
      status: 'Scheduled',
      travelerName: 'You (Verified)',
      travelerRating: '5.0 ★',
    );
    _trips.insert(0, newTrip);
    _activityFeed.insert(0, "New Trip posted: $departure → $destination (${capacity.toStringAsFixed(1)}kg)");
    notifyListeners();
  }

  void addPackage({
    required String desc,
    required double weight,
    required double reward,
    required String location,
  }) {
    final newPkg = PackageModel(
      id: 'CS-${(1000 + (DateTime.now().millisecondsSinceEpoch % 8999)).toString()}',
      senderId: _userId,
      itemDescription: desc,
      proposedReward: reward,
      pickupLat: 23.777176,
      pickupLng: 90.399452,
      routeInfo: '$location to Destination',
      eta: 'Pending Match',
      itemType: '$desc (${weight.toStringAsFixed(1)}kg)',
    );
    _packages.insert(0, newPkg);
    _activityFeed.insert(0, "New Package request posted: $desc (৳${reward.toStringAsFixed(0)})");
    notifyListeners();
  }
}
