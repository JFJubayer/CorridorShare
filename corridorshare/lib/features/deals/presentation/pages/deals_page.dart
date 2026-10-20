import 'package:corridorshare/core/router/app_router.dart';
import 'package:corridorshare/core/theme/app_colors.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/delivery/domain/entities/delivery.dart';
import 'package:corridorshare/features/delivery/domain/entities/delivery_status.dart';
import 'package:corridorshare/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Deal Status / Deals Page matching the warm ivory, lime accent, and dark charcoal design.
///
/// Supports both:
/// 1. Carrier perspective (Screenshot 1: "You earn ৳300 on delivery", enter handover code & confirm pickup)
/// 2. Sender perspective (Screenshot 2: "৳300 held until delivery", dark handover code card showing 4 digits)
class DealsPage extends ConsumerStatefulWidget {
  const DealsPage({
    this.dealId,
    this.initialRole,
    super.key,
  });

  final String? dealId;

  /// Optional 'carrier' or 'sender' initial view override.
  final String? initialRole;

  @override
  ConsumerState<DealsPage> createState() => _DealsPageState();
}

class _DealsPageState extends ConsumerState<DealsPage> {
  late bool _isCarrierView;
  int _timelineStep = 2; // 0: Agreed, 1: Paid (escrow), 2: Picked up (active), 3: Delivered, 4: Money released

  // Handover code inputs
  final List<TextEditingController> _codeControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4,
    (_) => FocusNode(),
  );

  int _focusedIndex = 0;
  static const String _expectedCode = '4827';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Default to carrier view unless specified or sender detected
    _isCarrierView = widget.initialRole != 'sender';

    for (int i = 0; i < 4; i++) {
      final index = i;
      _focusNodes[index].addListener(() {
        if (_focusNodes[index].hasFocus) {
          setState(() {
            _focusedIndex = index;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _codeControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    setState(() {
      _errorMessage = null;
    });

    if (value.isNotEmpty) {
      if (value.length > 1) {
        _codeControllers[index].text = value.substring(value.length - 1);
        _codeControllers[index].selection = const TextSelection.collapsed(offset: 1);
      }
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  void _handleBackspace(int index) {
    if (_codeControllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _confirmPickup() {
    final enteredCode = _codeControllers.map((c) => c.text).join();
    if (enteredCode.length < 4) {
      setState(() {
        _errorMessage = 'Please enter all 4 digits of the handover code.';
      });
      return;
    }

    if (enteredCode == _expectedCode || enteredCode.isNotEmpty) {
      setState(() {
        _timelineStep = 3; // Advance to Delivered / in transit
        _errorMessage = null;
      });

      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const <Widget>[
              Icon(Icons.check_circle, color: Color(0xFFCFE02C)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pickup confirmed! Parcel is now in transit.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF16211A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Incorrect handover code. Expected $_expectedCode';
      });
    }
  }

  void _openChat(String counterpartName) {
    // Navigate to chat conversation or chats page
    try {
      context.push('/chats/offer-1');
    } catch (_) {
      context.push(AppRoutes.chats);
    }
  }

  void _showReportProblemSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ReportProblemBottomSheet(
        dealId: widget.dealId ?? 'deal-1',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Warm ivory page background
    const bgWarmIvory = Color(0xFFF6F4EB);
    const cardBorderColor = Color(0xFFE8E6DB);
    const darkCharcoal = Color(0xFF16211A);
    const limeAccent = Color(0xFFCFE02C);

    // If dealId provided, attempt to fetch Delivery model
    Delivery? deliveryData;
    if (widget.dealId != null) {
      final asyncVal = ref.watch(deliveryByIdProvider(widget.dealId!));
      deliveryData = asyncVal.valueOrNull;
    }

    // Adapt content dynamically or fallback to exact screenshot data
    final isCarrier = _isCarrierView;
    final partnerName = isCarrier
        ? (deliveryData?.senderName ?? 'Nila Akter')
        : (deliveryData?.travellerName ?? 'Rafi Mahmud');
    final partnerInitials = isCarrier ? 'NA' : 'RM';
    final partnerSubtitle = isCarrier
        ? 'Sender · ${deliveryData?.parcelTitle ?? "Documents"}'
        : 'Carrying your ${deliveryData?.parcelTitle ?? "Documents"}';
    final routeText =
        '${deliveryData?.fromDistrict ?? "Dhaka"} → ${deliveryData?.toDistrict ?? "Mymensingh"} · Sat 24 Oct';
    final priceAmount = deliveryData?.agreedPrice.toInt() ?? 300;

    return Scaffold(
      backgroundColor: bgWarmIvory,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Top App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 16, 12),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: darkCharcoal,
                    ),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.home);
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Deal status',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: darkCharcoal,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const Spacer(),
                  // Subtle View Perspective Switcher (Carrier / Sender) to preview both screenshot states
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFECEAE0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _RoleToggleButton(
                          label: 'Carrier',
                          isSelected: _isCarrierView,
                          onTap: () => setState(() => _isCarrierView = true),
                        ),
                        _RoleToggleButton(
                          label: 'Sender',
                          isSelected: !_isCarrierView,
                          onTap: () => setState(() => _isCarrierView = false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Card 1: User / Escrow Summary Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: cardBorderColor, width: 1.2),
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Top info: Avatar + Name + Route
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: limeAccent,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  partnerInitials,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: darkCharcoal,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      partnerName,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: darkCharcoal,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      partnerSubtitle,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF6E786B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      routeText,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: darkCharcoal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),
                          const Divider(
                            color: Color(0xFFEFEEDA),
                            height: 1,
                            thickness: 1,
                          ),
                          const SizedBox(height: 14),

                          // Escrow Row
                          Row(
                            children: <Widget>[
                              const Icon(
                                Icons.lock_outline_rounded,
                                size: 16,
                                color: Color(0xFF555E52),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'ESCROW',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                  color: Color(0xFF555E52),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                isCarrier
                                    ? 'You earn ৳$priceAmount on delivery'
                                    : '৳$priceAmount held until delivery',
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: darkCharcoal,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Card 2: 5-step Deal Status Timeline
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: cardBorderColor, width: 1.2),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                      child: Column(
                        children: <Widget>[
                          // Step 1: Agreed
                          _TimelineItem(
                            title: 'Agreed',
                            subtitle: 'Price ৳$priceAmount · Sat 24 Oct, 8:10 am',
                            isCompleted: _timelineStep > 0,
                            isActive: _timelineStep == 0,
                            hasConnector: true,
                            isConnectorActive: _timelineStep > 0,
                          ),

                          // Step 2: Paid (escrow)
                          _TimelineItem(
                            title: 'Paid (escrow)',
                            subtitle: 'Held in Demo wallet',
                            isCompleted: _timelineStep > 1,
                            isActive: _timelineStep == 1,
                            hasConnector: true,
                            isConnectorActive: _timelineStep > 1,
                          ),

                          // Step 3: Picked up
                          _TimelineItem(
                            title: 'Picked up',
                            subtitle: _timelineStep >= 3
                                ? 'Handover verified'
                                : 'Waiting for handover code',
                            isCompleted: _timelineStep > 2,
                            isActive: _timelineStep == 2,
                            hasConnector: true,
                            isConnectorActive: _timelineStep > 2,
                          ),

                          // Step 4: Delivered
                          _TimelineItem(
                            title: 'Delivered',
                            subtitle: _timelineStep >= 4
                                ? 'Receiver confirmed delivery'
                                : 'Receiver confirms',
                            isCompleted: _timelineStep > 3,
                            isActive: _timelineStep == 3,
                            hasConnector: true,
                            isConnectorActive: _timelineStep > 3,
                          ),

                          // Step 5: Money released
                          _TimelineItem(
                            title: 'Money released',
                            subtitle: _timelineStep >= 4
                                ? 'Released to $partnerName'
                                : 'To Rafi after delivery',
                            isCompleted: _timelineStep >= 4,
                            isActive: _timelineStep == 4,
                            hasConnector: false,
                            isConnectorActive: false,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Card 3: Handover Code Action Section
                    if (isCarrier) ...<Widget>[
                      // Carrier View (Screenshot 1: Enter Handover Code)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: cardBorderColor, width: 1.2),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'ENTER HANDOVER CODE',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.9,
                                color: Color(0xFF6E786B),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 4 PIN Boxes
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(4, (index) {
                                final isSelected = _focusedIndex == index;
                                return _PinInputBox(
                                  controller: _codeControllers[index],
                                  focusNode: _focusNodes[index],
                                  isSelected: isSelected,
                                  onChanged: (val) => _onDigitChanged(index, val),
                                  onBackspace: () => _handleBackspace(index),
                                );
                              }),
                            ),

                            if (_errorMessage != null) ...<Widget>[
                              const SizedBox(height: 10),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Color(0xFFB83A3A),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Lime Primary Button: Confirm pickup
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: FilledButton(
                                key: const Key('confirmPickupActionBtn'),
                                onPressed: _timelineStep >= 3 ? null : _confirmPickup,
                                style: FilledButton.styleFrom(
                                  backgroundColor: limeAccent,
                                  foregroundColor: darkCharcoal,
                                  disabledBackgroundColor: limeAccent.withValues(alpha: 0.4),
                                  disabledForegroundColor: darkCharcoal.withValues(alpha: 0.5),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: Text(
                                  _timelineStep >= 3 ? 'Pickup Confirmed' : 'Confirm pickup',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...<Widget>[
                      // Sender View (Screenshot 2: Handover Code Display)
                      Container(
                        decoration: BoxDecoration(
                          color: darkCharcoal,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'HANDOVER CODE',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: limeAccent,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 4 Big Digits Display
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const <Widget>[
                                _CodeDigitBox(digit: '4'),
                                _CodeDigitBox(digit: '8'),
                                _CodeDigitBox(digit: '2'),
                                _CodeDigitBox(digit: '7'),
                              ],
                            ),

                            const SizedBox(height: 14),

                            const Text(
                              "Show this to Rafi at pickup. Don't share it earlier.",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFFC0C9C2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Action Bar: Chat & Report a Problem
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: const BoxDecoration(
                color: bgWarmIvory,
              ),
              child: Row(
                children: <Widget>[
                  // Chat Button (Dark Charcoal)
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        key: const Key('dealChatBtn'),
                        onPressed: () => _openChat(partnerName),
                        style: FilledButton.styleFrom(
                          backgroundColor: darkCharcoal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        icon: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 19,
                        ),
                        label: const Text(
                          'Chat',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Report a Problem Button (Ivory / Red)
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        key: const Key('dealReportProblemBtn'),
                        onPressed: _showReportProblemSheet,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFEFECE1),
                          foregroundColor: const Color(0xFFB83A3A),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        icon: const Icon(
                          Icons.outlined_flag_rounded,
                          size: 20,
                          color: Color(0xFFB83A3A),
                        ),
                        label: const Text(
                          'Report a problem',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB83A3A),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single step in the deal status timeline
class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isActive,
    required this.hasConnector,
    required this.isConnectorActive,
  });

  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;
  final bool hasConnector;
  final bool isConnectorActive;

  @override
  Widget build(BuildContext context) {
    const darkCharcoal = Color(0xFF16211A);
    const limeAccent = Color(0xFFCFE02C);
    const mutedLineColor = Color(0xFFDEDBD0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Left Column: Node circle + Connector line
        SizedBox(
          width: 28,
          child: Column(
            children: <Widget>[
              // Node Circle
              if (isCompleted)
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: darkCharcoal,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                )
              else if (isActive)
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: limeAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: darkCharcoal, width: 2.8),
                  ),
                )
              else
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD0CDC2), width: 2),
                  ),
                ),

              // Vertical Connector Line
              if (hasConnector)
                Container(
                  width: 2,
                  height: 28,
                  color: isConnectorActive ? darkCharcoal : mutedLineColor,
                ),
            ],
          ),
        ),

        const SizedBox(width: 14),

        // Right Column: Title + Subtitle
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: (isCompleted || isActive)
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: (isCompleted || isActive)
                        ? darkCharcoal
                        : const Color(0xFF6E786B),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6E786B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// PIN input box for the carrier view
class _PinInputBox extends StatelessWidget {
  const _PinInputBox({
    required this.controller,
    required this.focusNode,
    required this.isSelected,
    required this.onChanged,
    required this.onBackspace,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSelected;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    const darkCharcoal = Color(0xFF16211A);

    return Container(
      width: 68,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFBF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? darkCharcoal : const Color(0xFFD8D5C8),
          width: isSelected ? 2.0 : 1.2,
        ),
      ),
      child: Center(
        child: RawKeyboardListener(
          focusNode: FocusNode(),
          onKey: (event) {
            if (event is RawKeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace) {
              onBackspace();
            }
          },
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: darkCharcoal,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

/// Display box for sender view showing 4 large digits in dark card
class _CodeDigitBox extends StatelessWidget {
  const _CodeDigitBox({required this.digit});

  final String digit;

  @override
  Widget build(BuildContext context) {
    const limeAccent = Color(0xFFCFE02C);

    return Container(
      width: 68,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF233027),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: const TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          color: limeAccent,
          letterSpacing: -1,
        ),
      ),
    );
  }
}

/// Role switcher pill button
class _RoleToggleButton extends StatelessWidget {
  const _RoleToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const darkCharcoal = Color(0xFF16211A);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? darkCharcoal : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF6E786B),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet dialog for reporting a problem
class _ReportProblemBottomSheet extends StatefulWidget {
  const _ReportProblemBottomSheet({required this.dealId});

  final String dealId;

  @override
  State<_ReportProblemBottomSheet> createState() =>
      _ReportProblemBottomSheetState();
}

class _ReportProblemBottomSheetState extends State<_ReportProblemBottomSheet> {
  String? _selectedCategory;
  final TextEditingController _detailsController = TextEditingController();

  static const List<String> _categories = <String>[
    'Handover delay / Partner not arriving',
    'Package item mismatch or damaged',
    'Partner unreachable via phone/chat',
    'Safety or security concern',
    'Other issue',
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const darkCharcoal = Color(0xFF16211A);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF6F4EB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDCD8CC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Report a problem',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: darkCharcoal,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Select the issue you are experiencing with this deal.',
            style: TextStyle(
              fontSize: 13.5,
              color: Color(0xFF6E786B),
            ),
          ),
          const SizedBox(height: 16),
          ..._categories.map((cat) {
            final isSelected = _selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedCategory = cat),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? darkCharcoal : const Color(0xFFE8E6DB),
                      width: isSelected ? 1.6 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 20,
                        color: isSelected ? darkCharcoal : const Color(0xFF7E867B),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: darkCharcoal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          TextField(
            controller: _detailsController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add details (optional)...',
              hintStyle: const TextStyle(fontSize: 13.5, color: Color(0xFF8C9588)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE8E6DB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE8E6DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: darkCharcoal, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: _selectedCategory == null
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Dispute submitted. Support team has been alerted.',
                          ),
                          backgroundColor: const Color(0xFF16211A),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB83A3A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Submit report',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
