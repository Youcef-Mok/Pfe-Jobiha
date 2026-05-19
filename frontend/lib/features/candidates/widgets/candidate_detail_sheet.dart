// features/candidates/widgets/candidate_detail_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:job_app/features/candidates/domain/candidate_entity.dart';
import 'package:job_app/features/candidates/data/providers/candidates_provider.dart';

class CandidateDetailSheet extends ConsumerStatefulWidget {
  final CandidateEntity candidate;

  const CandidateDetailSheet({
    super.key,
    required this.candidate,
  });

  @override
  ConsumerState<CandidateDetailSheet> createState() =>
      _CandidateDetailSheetState();
}

class _CandidateDetailSheetState extends ConsumerState<CandidateDetailSheet> {
  DateTime? selectedDate;
  String selectedTimeSlot = '09:00 AM - 10:00 AM';

  final List<String> timeSlots = [
    '09:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '02:00 PM - 03:00 PM',
    '03:00 PM - 04:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 358,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 50,
            offset: Offset(0, 25),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header avec photo et infos
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo et badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(widget.candidate.photoUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (widget.candidate.isTopRated) ...[
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC1AA62),
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0D000000),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Text(
                          'TOP RATED',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: Color(0xFF4E3E00),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(width: 28),
                // Infos candidat
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.candidate.name,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          height: 20 / 20,
                          color: Color(0xFF401E66),
                        ),
                      ),
                      const SizedBox(height: 0),
                      Text(
                        widget.candidate.title,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 20 / 14,
                          color: Color(0xFF4A454F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 12,
                            color: Color(0xFF6F5D1D),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.candidate.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              height: 24 / 16,
                              color: Color(0xFF1D1B1F),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${widget.candidate.reviewsCount} Reviews)',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              height: 16 / 12,
                              color: Color(0xFF7C7580),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          // Cover letter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              widget.candidate.coverLetter,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 13,
                height: 23 / 13,
                color: Color(0xFF55505A),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Schedule Interview Section
          Container(
            width: 358,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Color(0xFF3A1B5E),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Schedule an Interview',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 28 / 16,
                        color: Color(0xFF3A1B5E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Date picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DATE',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Color(0xFF4A454F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                        }
                      },
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F3F8),
                          border: Border.all(color: const Color(0xFFE7E0E7)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              selectedDate != null
                                  ? DateFormat('MM/dd/yyyy')
                                      .format(selectedDate!)
                                  : 'mm/dd/yyyy',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                color: Color(0xFF1D1B1F),
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: Color(0xFF1D1B1F),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 17),
                // Time slot picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TIME SLOT',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Color(0xFF4A454F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 46,
                      padding: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F3F8),
                        border: Border.all(color: const Color(0xFFE7E0E7)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedTimeSlot,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: Color(0xFF1D1B1F),
                          ),
                          onChanged: (String? value) {
                            if (value != null) {
                              setState(() => selectedTimeSlot = value);
                            }
                          },
                          items: timeSlots.map((String slot) {
                            return DropdownMenuItem<String>(
                              value: slot,
                              child: Text(slot),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Accept button
          Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 10),
            child: Container(
              width: 326,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFF3A1B5E),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 10,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    if (selectedDate != null) {
                      await ref
                          .read(candidatesNotifierProvider.notifier)
                          .scheduleInterview(
                            widget.candidate.id,
                            selectedDate!,
                            selectedTimeSlot,
                          );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Interview scheduled successfully'),
                            backgroundColor: Color(0xFF3A1B5E),
                          ),
                        );
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Accept apply',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 14,
                          color: Color(0xFF3A1B5E),
                        ),
                      ),
                    ],
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
