import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/config/app_config.dart';
import '../core/geo/bangladesh_geo.dart';
import '../core/theme/app_colors.dart';
import '../models/trip_model.dart';
import '../providers/user_provider.dart';
import '../widgets/surcharge_calculator.dart';
import '../widgets/ui.dart';
import 'deal_chat_screen.dart';
import 'match_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // ---------------------------------------------------------------------------
  // Post trip / package
  // ---------------------------------------------------------------------------

  void _showPostModal(BuildContext context, bool isTraveler) {
    final provider = Provider.of<UserProvider>(context, listen: false);
    final descController = TextEditingController(text: 'Documents envelope');
    final rewardController = TextEditingController(text: '450');
    final weightController = TextEditingController(text: '5.0');
    final recipientController = TextEditingController();
    String? departureId = BangladeshGeo.places.first.id;
    String? destinationId = BangladeshGeo.places[1].id;
    String? pickupId = BangladeshGeo.places.first.id;
    String? dropoffId = BangladeshGeo.places[5].id;
    String? formError;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Future<void> submit() async {
              final capacity = double.tryParse(weightController.text);
              final reward = double.tryParse(rewardController.text);
              try {
                if (isTraveler) {
                  if (capacity == null || capacity <= 0) {
                    throw ArgumentError('Capacity must be a positive number.');
                  }
                  final dep = BangladeshGeo.byId(departureId ?? '');
                  final dest = BangladeshGeo.byId(destinationId ?? '');
                  if (dep == null || dest == null) {
                    throw ArgumentError('Select valid places.');
                  }
                  final route = BangladeshGeo.routeBetween(dep, dest);
                  await provider.addTrip(
                    departure: dep.label,
                    destination: dest.label,
                    date: 'soon',
                    capacity: capacity,
                    routePoints: route,
                  );
                } else {
                  if (reward == null || reward <= 0) {
                    throw ArgumentError('Reward must be a positive amount.');
                  }
                  if (capacity == null || capacity <= 0) {
                    throw ArgumentError('Weight must be a positive number.');
                  }
                  final pickup = BangladeshGeo.byId(pickupId ?? '');
                  final dropoff = BangladeshGeo.byId(dropoffId ?? '');
                  if (pickup == null || dropoff == null) {
                    throw ArgumentError(
                        'Select valid pickup and dropoff places.');
                  }
                  if (pickup.id == dropoff.id) {
                    throw ArgumentError('Dropoff must differ from pickup.');
                  }
                  final phone = recipientController.text.trim();
                  if (phone.isEmpty) {
                    throw ArgumentError('Recipient phone is required.');
                  }
                  await provider.addPackage(
                    desc: descController.text,
                    weight: capacity,
                    reward: reward,
                    pickup: pickup.point,
                    dropoff: dropoff.point,
                    routeInfo: '${pickup.label} → ${dropoff.label}',
                    recipientPhone: phone,
                  );
                }
              } on Object catch (error) {
                if (!ctx.mounted) return;
                setModalState(() => formError = '$error');
                return;
              }
              if (!ctx.mounted || !context.mounted) return;
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(isTraveler
                        ? 'Trip posted.'
                        : 'Delivery request posted.')),
              );
            }

            List<DropdownMenuItem<String>> placeItems(
                    {bool withRegion = false}) =>
                [
                  for (final p in BangladeshGeo.places)
                    DropdownMenuItem(
                      value: p.id,
                      child: Text(
                          withRegion ? '${p.label} (${p.region})' : p.label),
                    ),
                ];

            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTraveler ? 'Post a trip' : 'Send a package',
                      style: ctx.tt.headlineSmall,
                    ),
                    Gap.xs,
                    Text(
                      isTraveler
                          ? 'Your route is built from the places you choose.'
                          : 'Travelers along this route can offer to carry it.',
                      style: ctx.tt.bodyMedium,
                    ),
                    Gap.lg,
                    if (isTraveler) ...[
                      DropdownButtonFormField<String>(
                        initialValue: departureId,
                        decoration:
                            const InputDecoration(labelText: 'Departure'),
                        items: placeItems(withRegion: true),
                        onChanged: (v) => setModalState(() => departureId = v),
                      ),
                      Gap.md,
                      DropdownButtonFormField<String>(
                        initialValue: destinationId,
                        decoration:
                            const InputDecoration(labelText: 'Destination'),
                        items: placeItems(withRegion: true),
                        onChanged: (v) =>
                            setModalState(() => destinationId = v),
                      ),
                      Gap.md,
                      TextField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Available capacity',
                          suffixText: 'kg',
                        ),
                      ),
                    ] else ...[
                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(
                            labelText: 'What are you sending?'),
                      ),
                      Gap.md,
                      DropdownButtonFormField<String>(
                        initialValue: pickupId,
                        decoration: const InputDecoration(labelText: 'Pickup'),
                        items: placeItems(),
                        onChanged: (v) => setModalState(() => pickupId = v),
                      ),
                      Gap.md,
                      DropdownButtonFormField<String>(
                        initialValue: dropoffId,
                        decoration: const InputDecoration(labelText: 'Dropoff'),
                        items: placeItems(),
                        onChanged: (v) => setModalState(() => dropoffId = v),
                      ),
                      Gap.md,
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: rewardController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Reward',
                                prefixText: '৳ ',
                              ),
                            ),
                          ),
                          Gap.md,
                          Expanded(
                            child: TextField(
                              controller: weightController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Weight',
                                suffixText: 'kg',
                              ),
                            ),
                          ),
                        ],
                      ),
                      Gap.md,
                      TextField(
                        controller: recipientController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Recipient phone',
                          helperText: 'Used to issue the delivery OTP.',
                        ),
                      ),
                    ],
                    if (formError != null) ...[
                      Gap.md,
                      InlineNotice(formError!, tone: StatusTone.danger),
                    ],
                    Gap.lg,
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: submit,
                        child: Text(isTraveler ? 'Post trip' : 'Post request'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      descController.dispose();
      rewardController.dispose();
      weightController.dispose();
      recipientController.dispose();
    });
  }

  // ---------------------------------------------------------------------------
  // Wallet
  // ---------------------------------------------------------------------------

  void _showTopUpSheet(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.dataMode != AppDataMode.demo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Live top-up is off in the beta. Ask an admin to credit your wallet.'),
        ),
      );
      return;
    }

    final amountController = TextEditingController(text: '500');
    var providerName = 'bKash';
    String? error;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          Future<void> confirm() async {
            final amt = double.tryParse(amountController.text);
            if (amt == null || amt <= 0) {
              setSheetState(() => error = 'Amount must be positive.');
              return;
            }
            try {
              if (providerName == 'bKash') {
                await userProvider.topUpBkash(amt);
              } else {
                await userProvider.topUpNagad(amt);
              }
            } on Object catch (e) {
              if (!ctx.mounted) return;
              setSheetState(() => error = '$e');
              return;
            }
            if (!ctx.mounted || !context.mounted) return;
            Navigator.of(ctx).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Added ৳${amt.toStringAsFixed(0)} via $providerName.')),
            );
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(
                24, 0, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add funds', style: ctx.tt.headlineSmall),
                Gap.xs,
                Text('Demo wallet only. No real charge is made.',
                    style: ctx.tt.bodyMedium),
                Gap.lg,
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'bKash', label: Text('bKash')),
                    ButtonSegment(value: 'Nagad', label: Text('Nagad')),
                  ],
                  selected: {providerName},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) =>
                      setSheetState(() => providerName = s.first),
                ),
                Gap.md,
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: ctx.tt.headlineSmall,
                  decoration: InputDecoration(
                    prefixText: '৳ ',
                    prefixStyle: ctx.tt.headlineSmall,
                    errorText: error,
                  ),
                ),
                Gap.lg,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                      onPressed: confirm, child: const Text('Add funds')),
                ),
              ],
            ),
          );
        },
      ),
    ).whenComplete(amountController.dispose);
  }

  // ---------------------------------------------------------------------------
  // NID
  // ---------------------------------------------------------------------------

  Future<void> _uploadNidPhoto(BuildContext context) async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    if (provider.dataMode != AppDataMode.supabase) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NID upload needs live mode.')),
      );
      return;
    }
    final picker = ImagePicker();
    final file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    try {
      final bytes = await file.readAsBytes();
      await provider.uploadNidPhoto(
        bytes: bytes,
        fileName: 'nid-${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('NID photo uploaded. An admin will review it.')),
      );
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  // ---------------------------------------------------------------------------
  // Account sheet
  // ---------------------------------------------------------------------------

  void _showAccountSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final userProvider = ctx.watch<UserProvider>();
        final nid = userProvider.nidStatus;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account', style: ctx.tt.headlineSmall),
                Gap.md,
                KeyValueGroup(
                  children: [
                    KeyValueRow(
                        'Phone',
                        userProvider.phone.isEmpty
                            ? 'Not set'
                            : userProvider.phone),
                    KeyValueRow('NID status', _nidLabel(nid),
                        valueColor: _nidColor(ctx, nid)),
                    KeyValueRow('Available',
                        '৳ ${userProvider.availableWalletBalance.toStringAsFixed(2)}'),
                    KeyValueRow('In escrow',
                        '৳ ${userProvider.escrowLockedBalance.toStringAsFixed(2)}'),
                  ],
                ),
                Gap.md,
                Text('Appearance', style: ctx.tt.labelMedium),
                Gap.sm,
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                        value: ThemeMode.system, label: Text('System')),
                    ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                  ],
                  selected: {userProvider.themeMode},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => userProvider.setThemeMode(s.first),
                ),
                Gap.lg,
                if (nid != 'verified')
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _uploadNidPhoto(context);
                      },
                      icon: const Icon(Icons.badge_outlined, size: 18),
                      label: Text(nid == 'pending'
                          ? 'Replace NID photo'
                          : 'Upload NID photo'),
                    ),
                  ),
                if (nid != 'verified') Gap.sm,
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await userProvider.logout();
                    },
                    style: TextButton.styleFrom(
                        foregroundColor: ctx.appColors.danger),
                    child: const Text('Log out'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _nidLabel(String status) => switch (status) {
        'verified' => 'Verified',
        'pending' => 'Under review',
        'suspended' => 'Suspended',
        _ => 'Not verified',
      };

  static Color? _nidColor(BuildContext context, String status) =>
      switch (status) {
        'verified' => context.appColors.ok,
        'suspended' => context.appColors.danger,
        _ => null,
      };

  // ---------------------------------------------------------------------------
  // Request capacity on a trip
  // ---------------------------------------------------------------------------

  void _requestCapacityOnTrip(BuildContext context, TripModel trip) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final myPackages = userProvider.packages
        .where((pkg) => pkg.senderId == userProvider.userId)
        .toList(growable: false);

    if (myPackages.isEmpty) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Post a package first'),
          content: const Text(
            'You need a package request before you can open a deal on this trip.',
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showPostModal(context, false);
              },
              child: const Text('Send a package'),
            ),
          ],
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  'Choose a package for ${trip.departureCity} → ${trip.destinationCity}',
                  style: ctx.tt.titleLarge,
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(ctx).size.height * 0.45),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: myPackages.length,
                  separatorBuilder: (_, __) =>
                      const Divider(indent: 24, endIndent: 24),
                  itemBuilder: (_, idx) {
                    final pkg = myPackages[idx];
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      title: Text(pkg.itemDescription),
                      subtitle: Text(pkg.routeInfo),
                      trailing: Text(
                          '৳ ${pkg.proposedReward.toStringAsFixed(0)}',
                          style: ctx.tt.titleSmall),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                DealChatScreen(package: pkg, tripId: trip.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => MatchScreen(initialTripId: trip.id)),
                    );
                  },
                  child: const Text('Open in Matching instead'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isTraveler = userProvider.isTraveler;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Text('CorridorShare'),
        actions: [
          IconButton(
            onPressed: () => _showAccountSheet(context),
            tooltip: 'Account',
            icon: const Icon(Icons.person_outline),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          _RoleSwitch(
            isTraveler: isTraveler,
            onChanged: (role) => userProvider.setRole(role),
          ),
          Gap.lg,
          _WalletSummary(
            provider: userProvider,
            onAddFunds: () => _showTopUpSheet(context),
            onPrimary: () => _showPostModal(context, isTraveler),
            primaryLabel: isTraveler ? 'Post a trip' : 'Send a package',
          ),
          Gap.xl,
          _SetupChecklist(
            provider: userProvider,
            onUploadNid: () => _uploadNidPhoto(context),
            onAccount: () => _showAccountSheet(context),
            onPost: () => _showPostModal(context, isTraveler),
            onMatch: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MatchScreen()),
            ),
          ),
          SectionHeader(
            'Trips on the corridor',
            action: userProvider.trips.isEmpty ? null : 'See all',
            onAction: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MatchScreen()),
            ),
          ),
          Gap.sm,
          if (userProvider.trips.isEmpty)
            Panel(
              child: Text(
                isTraveler
                    ? 'No trips yet. Post one to start receiving package requests.'
                    : 'No trips yet. Post a package so travelers can find it.',
                style: context.tt.bodyMedium,
              ),
            )
          else
            SizedBox(
              height: 148,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: userProvider.trips.length,
                separatorBuilder: (_, __) => Gap.sm,
                itemBuilder: (ctx, idx) => _TripCard(
                  trip: userProvider.trips[idx],
                  onRequest: () =>
                      _requestCapacityOnTrip(context, userProvider.trips[idx]),
                ),
              ),
            ),
          Gap.xl,
          if (isTraveler) ...[
            const SectionHeader('Estimate earnings'),
            Gap.sm,
            SurchargeCalculatorWidget(
                onShipPressed: () => _showPostModal(context, true)),
            Gap.xl,
          ],
          const SectionHeader('How a delivery works'),
          Gap.sm,
          const _Steps(),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Pieces
// -----------------------------------------------------------------------------

class _RoleSwitch extends StatelessWidget {
  const _RoleSwitch({required this.isTraveler, required this.onChanged});

  final bool isTraveler;
  final ValueChanged<AppRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AppRole>(
      segments: const [
        ButtonSegment(
          value: AppRole.sender,
          label: Text('Sending'),
          icon: Icon(Icons.inventory_2_outlined, size: 16),
        ),
        ButtonSegment(
          value: AppRole.traveler,
          label: Text('Travelling'),
          icon: Icon(Icons.directions_car_outlined, size: 16),
        ),
      ],
      selected: {isTraveler ? AppRole.traveler : AppRole.sender},
      showSelectedIcon: false,
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _WalletSummary extends StatelessWidget {
  const _WalletSummary({
    required this.provider,
    required this.onAddFunds,
    required this.onPrimary,
    required this.primaryLabel,
  });

  final UserProvider provider;
  final VoidCallback onAddFunds;
  final VoidCallback onPrimary;
  final String primaryLabel;

  @override
  Widget build(BuildContext context) {
    final available = provider.availableWalletBalance;
    final held = provider.escrowLockedBalance;
    final liveMode = provider.dataMode != AppDataMode.demo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Available balance', style: context.tt.labelMedium),
        Gap.xs,
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.15), end: Offset.zero)
                  .animate(anim),
              child: child,
            ),
          ),
          child: Text(
            '৳ ${available.toStringAsFixed(2)}',
            key: ValueKey(available),
            style: context.tt.headlineMedium?.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
        ),
        Gap.sm,
        Text(
          held > 0
              ? '৳ ${held.toStringAsFixed(2)} held in escrow'
              : 'Nothing held in escrow',
          style: context.tt.bodyMedium,
        ),
        if (liveMode) ...[
          Gap.sm,
          const InlineNotice(
              'Live top-up is off. An admin credits beta wallets.'),
        ],
        Gap.md,
        Row(
          children: [
            Expanded(
              child:
                  FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
            ),
            Gap.sm,
            OutlinedButton(
              onPressed: onAddFunds,
              child: const Text('Add funds'),
            ),
          ],
        ),
      ],
    );
  }
}

class _SetupChecklist extends StatelessWidget {
  const _SetupChecklist({
    required this.provider,
    required this.onUploadNid,
    required this.onAccount,
    required this.onPost,
    required this.onMatch,
  });

  final UserProvider provider;
  final VoidCallback onUploadNid;
  final VoidCallback onAccount;
  final VoidCallback onPost;
  final VoidCallback onMatch;

  @override
  Widget build(BuildContext context) {
    final nidDone =
        provider.nidStatus == 'verified' || provider.nidStatus == 'pending';
    final listingDone =
        provider.trips.isNotEmpty || provider.packages.isNotEmpty;
    final dealDone = provider.deals.isNotEmpty;
    final walletOk = provider.availableWalletBalance > 0;
    if (nidDone && listingDone && dealDone && walletOk) {
      return const SizedBox.shrink();
    }

    final items = <_ChecklistItem>[
      _ChecklistItem('Verify your NID', nidDone, 'Upload', onUploadNid),
      _ChecklistItem('Fund your wallet', walletOk, 'Account', onAccount),
      _ChecklistItem(
        provider.isTraveler
            ? 'Post your first trip'
            : 'Post your first package',
        listingDone,
        'Post',
        onPost,
      ),
      _ChecklistItem('Open a deal from Matching', dealDone, 'Match', onMatch),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Getting started'),
        Gap.sm,
        Panel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const Divider(indent: 48),
                ListTile(
                  dense: true,
                  leading: Icon(
                    items[i].done ? Icons.check_circle : Icons.circle_outlined,
                    size: 20,
                    color: items[i].done
                        ? context.appColors.ok
                        : context.cs.onSurfaceVariant,
                  ),
                  title: Text(
                    items[i].title,
                    style: context.tt.bodyLarge?.copyWith(
                      color: items[i].done
                          ? context.cs.onSurfaceVariant
                          : context.cs.onSurface,
                      decoration:
                          items[i].done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  trailing: items[i].done
                      ? null
                      : TextButton(
                          onPressed: items[i].onTap,
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: Text(items[i].cta),
                        ),
                ),
              ],
            ],
          ),
        ),
        Gap.xl,
      ],
    );
  }
}

class _ChecklistItem {
  const _ChecklistItem(this.title, this.done, this.cta, this.onTap);
  final String title;
  final bool done;
  final String cta;
  final VoidCallback onTap;
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip, required this.onRequest});

  final TripModel trip;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Panel(
        onTap: onRequest,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InitialsAvatar(trip.travelerName, radius: 14),
                Gap.sm,
                Expanded(
                  child: Text(
                    trip.travelerName,
                    style: context.tt.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(trip.travelerRatingLabel, style: context.tt.labelMedium),
              ],
            ),
            const Spacer(),
            Text(
              '${trip.departureCity} → ${trip.destinationCity}',
              style:
                  context.tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Gap.xs,
            Text(
              '${trip.travelTimeLabel} · up to ${trip.weightCapacityKg.toStringAsFixed(0)} kg',
              style: context.tt.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps();

  static const _steps = [
    (
      Icons.handshake_outlined,
      'Match and agree',
      'Find a traveler on your route and settle the price in chat.'
    ),
    (
      Icons.inventory_2_outlined,
      'Inspect and lock',
      'Both sides photograph the open box, then funds lock in escrow.'
    ),
    (
      Icons.verified_user_outlined,
      'Deliver and release',
      'The recipient shares a one-time code that releases payment.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _steps.length; i++) ...[
          if (i > 0) const Divider(indent: 36),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_steps[i].$1,
                    size: 20, color: context.cs.onSurfaceVariant),
                Gap.md,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_steps[i].$2, style: context.tt.titleSmall),
                      Gap.xs,
                      Text(_steps[i].$3, style: context.tt.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
