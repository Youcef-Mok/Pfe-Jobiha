import 'package:flutter/material.dart';

class CandidateFilterOverlay extends StatefulWidget {
  final String initialFilter;
  final double topOffset;

  const CandidateFilterOverlay({
    super.key,
    this.initialFilter = '',
    this.topOffset = 83,
  });

  @override
  State<CandidateFilterOverlay> createState() => _CandidateFilterOverlayState();
}

class _CandidateFilterOverlayState extends State<CandidateFilterOverlay> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.topRight,
      insetPadding: EdgeInsets.only(top: widget.topOffset, right: 16),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: UnconstrainedBox(
        alignment: Alignment.topRight,
        child: Container(
          width: 171,
          padding: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFEDF2),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000), // rgba(0, 0, 0, 0.25)
                blurRadius: 50,
                offset: Offset(0, 25),
                spreadRadius: -12,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: const BoxConstraints(maxHeight: 132),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _OverlayOptionRow(
                        label: 'plus recent',
                        icon: Icons.history,
                        isSelected: _selected == 'recent',
                        onTap: () {
                          setState(() => _selected = 'recent');
                          Navigator.pop(context, 'recent');
                        },
                      ),
                      _OverlayOptionRow(
                        label: 'plus proche',
                        icon: Icons.navigation_outlined,
                        isSelected: _selected == 'proche',
                        topBorder: true,
                        rotateIcon: true,
                        onTap: () {
                          setState(() => _selected = 'proche');
                          Navigator.pop(context, 'proche');
                        },
                      ),
                      _OverlayOptionRow(
                        label: 'Mieux paye',
                        icon: Icons.savings_outlined,
                        isSelected: _selected == 'mieux_paye',
                        topBorder: true,
                        onTap: () {
                          setState(() => _selected = 'mieux_paye');
                          Navigator.pop(context, 'mieux_paye');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFF4F4F5))),
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selected = '');
                    Navigator.pop(context, '');
                  },
                  child: const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Réinitialiser',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                        color: Color(0xFFA1A1AA),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverlayOptionRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool topBorder;
  final bool rotateIcon;
  final VoidCallback onTap;

  const _OverlayOptionRow({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.topBorder = false,
    this.rotateIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.fromLTRB(12, 8, 24, 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEBE6F2) : Colors.transparent,
          border: topBorder
              ? const Border(top: BorderSide(color: Color(0xFFFAFAFA)))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: isSelected ? 28 : 27,
              height: isSelected ? 28 : 27,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF513376)
                    : const Color(0xFFE8E1F4),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Transform.rotate(
                  angle: rotateIcon ? 0.785398 : 0, // approx pi/4
                  child: Icon(
                    icon,
                    size: isSelected ? 16 : 17,
                    color: isSelected ? Colors.white : const Color(0xFF401E66),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 13,
                  color: const Color(0xFF401E66),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3A1B5E)
                      : const Color(0xFFE4E4E7),
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3A1B5E),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
