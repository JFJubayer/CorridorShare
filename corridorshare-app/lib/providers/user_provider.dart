import 'package:flutter/foundation.dart';

import '../core/config/app_config.dart';
import '../core/money/money.dart';
import '../features/deals/deals_controller.dart';
import '../features/listings/listings_controller.dart';
import '../features/session/session_controller.dart';
import '../features/wallet/wallet_controller.dart';
import '../models/deal_model.dart';
import '../models/package_model.dart';
import '../models/trip_model.dart';
import '../infrastructure/supabase/supabase_backend_repository.dart';

export '../features/session/session_controller.dart' show AppRole, NidStatus;

/// Compatibility façade for the existing UI.
class UserProvider extends ChangeNotifier {
  factory UserProvider({
    AppConfig? config,
    SessionController? session,
    WalletController? wallet,
    ListingsController? listings,
    DealsController? deals,
  }) {
    final resolvedConfig = config ?? const AppConfig(dataMode: AppDataMode.supabase);
    final resolvedWallet = wallet ?? WalletController(config: resolvedConfig);
    final liveRepository = BackendRepositoryFactory.create(resolvedConfig);
    return UserProvider._(
      config: resolvedConfig,
      session: session ?? SessionController(config: resolvedConfig),
      wallet: resolvedWallet,
      listings: listings ?? ListingsController(config: resolvedConfig),
      deals: deals ?? DealsController(
        config: resolvedConfig,
        wallet: resolvedWallet,
        liveRepository: liveRepository,
      ),
      liveRepository: liveRepository,
    );
  }

  UserProvider._({
    required AppConfig config,
    required SessionController session,
    required WalletController wallet,
    required ListingsController listings,
    required DealsController deals,
    required SupabaseBackendRepository? liveRepository,
  })  : _config = config,
        _session = session,
        _wallet = wallet,
        _listings = listings,
        _deals = deals,
        _liveRepository = liveRepository {
    _session.addListener(_notify);
    _wallet.addListener(_notify);
    _listings.addListener(_notify);
    _deals.addListener(_notify);
  }

  final AppConfig _config;
  final SessionController _session;
  final WalletController _wallet;
  final ListingsController _listings;
  final DealsController _deals;
  final SupabaseBackendRepository? _liveRepository;
  String? _liveDataError;
  final List<String> _activityFeed = [
    'Demo activity is available only with DATA_MODE=demo.',
  ];

  AppDataMode get dataMode => _config.dataMode;
  AppRole get role => _session.role;
  bool get isTraveler => _session.isTraveler;
  bool get isAuthenticated => _session.isAuthenticated;
  String get phone => _session.phone;
  double get walletBalance => _wallet.totalBalance.asBdt;
  double get availableWalletBalance => _wallet.availableBalance.asBdt;
  double get escrowLockedBalance => _wallet.escrowBalance.asBdt;
  String get nidStatus => _session.nidStatus.name;
  bool get isDarkMode => _session.isDarkMode;
  String get userId => _session.userId;
  List<TripModel> get trips => _listings.trips;
  List<PackageModel> get packages => _listings.packages;
  List<PackageModel> get matchedPackages => _listings.matchedPackages;
  List<DealModel> get deals => _deals.deals;
  List<String> get activityFeed => List.unmodifiable(_activityFeed);
  DealsController get dealsController => _deals;
  ListingsController get listingsController => _listings;
  SupabaseBackendRepository? get liveRepository => _liveRepository;
  String? get liveDataError => _liveDataError;

  void toggleRole() => _session.toggleRole();
  void setRole(AppRole role) => _session.setRole(role);
  void toggleTheme() => _session.toggleTheme();

  Future<void> bootstrapSession() async {
    await _session.bootstrap();
    final repository = _liveRepository;
    if (repository != null && isAuthenticated) {
      await _hydrateLiveData(repository);
    }
  }

  Future<void> requestOtp(String phone) => _session.requestOtp(phone);
  Future<void> verifyOtp({required String phone, required String otp}) async {
    await _session.verifyOtp(phone: phone, otp: otp);
    final repository = _liveRepository;
    if (repository != null) {
      await _hydrateLiveData(repository);
    }
  }
  void startDemoSession(String phone) => _session.startDemoSession(phone);
  Future<void> logout() => _session.logout();

  Future<void> topUpBkash(double amount) => _topUp(amount, 'bKash');
  Future<void> topUpNagad(double amount) => _topUp(amount, 'Nagad');

  Future<void> addTrip({
    required String departure,
    required String destination,
    required String date,
    required double capacity,
    required List<GeoPoint> routePoints,
  }) async {
    await _listings.addTrip(
      currentUserId: userId,
      departure: departure,
      destination: destination,
      travelTime: DateTime.now().toUtc().add(const Duration(hours: 2)),
      capacity: capacity,
      routePoints: routePoints,
      liveRepository: _liveRepository,
    );
    _activityFeed.insert(0, 'New trip posted: $departure → $destination');
    notifyListeners();
  }

  Future<void> addPackage({
    required String desc,
    required double weight,
    required double reward,
    required GeoPoint pickup,
    required GeoPoint dropoff,
    required String routeInfo,
    String? recipientPhone,
    String? recipientName,
  }) async {
    await _listings.addPackage(
      currentUserId: userId,
      description: desc,
      weight: weight,
      reward: Money.fromBdt(reward),
      pickup: pickup,
      dropoff: dropoff,
      routeInfo: routeInfo,
      recipientPhone: recipientPhone,
      recipientName: recipientName,
      liveRepository: _liveRepository,
    );
    _activityFeed.insert(0, 'New package request posted: $desc');
    notifyListeners();
  }

  Future<List<PackageModel>> matchPackagesForTrip(String tripId) =>
      _listings.matchForTrip(tripId: tripId, liveRepository: _liveRepository);

  Future<String> uploadNidPhoto({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final repository = _liveRepository;
    if (repository == null) {
      throw UnsupportedError('NID photo upload requires live Supabase mode.');
    }
    final url = await repository.uploadEvidenceImage(
      folder: 'nid',
      fileName: fileName,
      bytes: bytes,
    );
    await repository.updateOwnNidPhoto(url);
    _session.applyServerProfile(nidStatus: 'pending');
    _activityFeed.insert(0, 'NID photo submitted for admin review.');
    notifyListeners();
    return url;
  }

  Future<String> uploadInspectionPhoto({
    required String dealId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final repository = _liveRepository;
    if (repository == null) {
      throw UnsupportedError('Inspection photo upload requires live Supabase mode.');
    }
    return repository.uploadEvidenceImage(
      folder: 'inspection',
      fileName: fileName,
      bytes: bytes,
      dealId: dealId,
    );
  }

  Future<void> _topUp(double amount, String provider) async {
    if (!_config.isDemo) {
      throw UnsupportedError(
        'Live $provider top-up is blocked: no payment provider is configured. '
        'Staging wallets are funded by an admin via admin_credit_wallet '
        '(not a client top-up). Provider credits remain wallet_credit_from_provider.',
      );
    }
    _wallet.topUp(amount: Money.fromBdt(amount), provider: provider);
    _activityFeed.insert(0, 'Top-up added via $provider.');
    notifyListeners();
  }

  Future<void> _hydrateLiveData(SupabaseBackendRepository repository) async {
    try {
      final profile = await repository.fetchCurrentProfile();
      final wallet = await repository.fetchCurrentWallet();
      _session.applyServerProfile(nidStatus: profile['nid_status'] as String);
      _wallet.applyServerBalances(
        availableMinor: (wallet['available_balance_minor'] as num).toInt(),
        heldMinor: (wallet['held_balance_minor'] as num).toInt(),
      );
      await _listings.hydrate(repository);
      await _deals.hydrate(repository);
      _liveDataError = null;
    } on Object catch (error) {
      _liveDataError = '$error';
      notifyListeners();
    }
  }

  void _notify() => notifyListeners();

  @override
  void dispose() {
    _session.removeListener(_notify);
    _wallet.removeListener(_notify);
    _listings.removeListener(_notify);
    _deals.removeListener(_notify);
    _session.dispose();
    _wallet.dispose();
    _listings.dispose();
    _deals.dispose();
    super.dispose();
  }
}
