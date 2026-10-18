import 'package:corridorshare/core/constants/bangladesh_districts.dart';
import 'package:corridorshare/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Reusable route card featuring From/To district dropdowns,
/// pickup/drop-off area text inputs, dotted route indicators, and a swap button.
class RouteSelectorCard extends StatelessWidget {
  const RouteSelectorCard({
    super.key,
    required this.fromDistrict,
    required this.toDistrict,
    required this.fromAreaController,
    required this.toAreaController,
    required this.onFromDistrictChanged,
    required this.onToDistrictChanged,
    required this.onSwap,
    this.fromDistrictValidator,
    this.toDistrictValidator,
  });

  final String? fromDistrict;
  final String? toDistrict;
  final TextEditingController fromAreaController;
  final TextEditingController toAreaController;
  final ValueChanged<String?> onFromDistrictChanged;
  final ValueChanged<String?> onToDistrictChanged;
  final VoidCallback onSwap;
  final FormFieldValidator<String>? fromDistrictValidator;
  final FormFieldValidator<String>? toDistrictValidator;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Stack(
        alignment: Alignment.centerRight,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Route indicator: hollow dot -> dotted line -> filled location pin
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.darkCharcoal,
                          width: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    ...List.generate(
                      5,
                      (int index) => Container(
                        width: 2,
                        height: 3,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.darkCharcoal.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.darkCharcoal,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Main inputs column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // FROM SECTION
                    const Text(
                      'FROM',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ticketMutedText,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.only(right: 36),
                      child: Row(
                        children: <Widget>[
                          // Origin Dropdown
                          Expanded(
                            flex: 11,
                            child: DropdownButtonFormField<String>(
                              key: const Key('fromDistrictDropdown'),
                              initialValue: fromDistrict,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: AppColors.darkCharcoal,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkCharcoal,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                                filled: false,
                                fillColor: Colors.transparent,
                                errorStyle: TextStyle(fontSize: 10, height: 1),
                              ),
                              items: BangladeshDistricts.all.map((String d) {
                                return DropdownMenuItem<String>(
                                  value: d,
                                  child: Text(
                                    d,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: onFromDistrictChanged,
                              validator: fromDistrictValidator,
                            ),
                          ),
                          Container(
                            height: 20,
                            width: 1,
                            color: AppColors.cardBorder,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          // Pickup Area Field
                          Expanded(
                            flex: 12,
                            child: TextFormField(
                              key: const Key('fromAreaField'),
                              controller: fromAreaController,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.darkCharcoal,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Pickup area',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.ticketMutedText,
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 4),
                                border: InputBorder.none,
                                filled: false,
                                fillColor: Colors.transparent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    const Divider(
                      color: AppColors.cardBorder,
                      height: 1,
                      thickness: 1,
                    ),
                    const SizedBox(height: 8),

                    // TO SECTION
                    const Text(
                      'TO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ticketMutedText,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.only(right: 36),
                      child: Row(
                        children: <Widget>[
                          // Destination Dropdown
                          Expanded(
                            flex: 11,
                            child: DropdownButtonFormField<String>(
                              key: const Key('toDistrictDropdown'),
                              initialValue: toDistrict,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: AppColors.darkCharcoal,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkCharcoal,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                                filled: false,
                                fillColor: Colors.transparent,
                                errorStyle: TextStyle(fontSize: 10, height: 1),
                              ),
                              items: BangladeshDistricts.all.map((String d) {
                                return DropdownMenuItem<String>(
                                  value: d,
                                  child: Text(
                                    d,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: onToDistrictChanged,
                              validator: toDistrictValidator,
                            ),
                          ),
                          Container(
                            height: 20,
                            width: 1,
                            color: AppColors.cardBorder,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          // Drop-off Area Field
                          Expanded(
                            flex: 12,
                            child: TextFormField(
                              key: const Key('toAreaField'),
                              controller: toAreaController,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.darkCharcoal,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Drop-off area',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.ticketMutedText,
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 4),
                                border: InputBorder.none,
                                filled: false,
                                fillColor: Colors.transparent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Circular Swap Button on Right
          Positioned(
            right: 0,
            child: Material(
              color: AppColors.darkCharcoal,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onSwap,
                child: const Padding(
                  padding: EdgeInsets.all(9),
                  child: Icon(
                    Icons.swap_vert,
                    color: AppColors.limeAccent,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
