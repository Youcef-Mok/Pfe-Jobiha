import 'package:flutter/material.dart';

// Data classes

class ContactItem {
  final String name;
  final String role;
  final String? avatar;
  final bool isOnline;
  final bool isRecruiter;

  const ContactItem({
    required this.name,
    required this.role,
    this.avatar,
    this.isOnline = false,
    this.isRecruiter = false,
  });
}

class JobGroup {
  final String jobTitle;
  final String company;
  final String? jobImage;
  final ContactItem recruiter;

  const JobGroup({
    required this.jobTitle,
    required this.company,
    this.jobImage,
    required this.recruiter,
  });
}

// Search bar

class MessageSearchBar extends StatelessWidget {
  const MessageSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEDF2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          SizedBox(width: 15),
          Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'search contacts or messages',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Section header

class MessageSectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const MessageSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF1D1B1F),
          ),
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF401E66),
              ),
            ),
          ),
      ],
    );
  }
}

// Trier Par Annonce toggle button

class SortByAnnonceButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const SortByAnnonceButton({
    super.key,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 32,
        padding: EdgeInsets.symmetric(horizontal: isActive ? 8 : 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEFEDF2),
          border: isActive
              ? Border.all(color: const Color(0xFF401E66), width: 0.5)
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              Container(
                width: 21,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF401E66),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(
                  Icons.notifications,
                  size: 11,
                  color: Colors.white,
                ),
              )
            else
              const Icon(
                Icons.notifications_none_outlined,
                size: 16,
                color: Color(0xFF401E66),
              ),
            const SizedBox(width: 6),
            Text(
              'trier Par annonce',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
                color: const Color(0xFF401E66),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Contacts card

class ContactsCard extends StatelessWidget {
  final List<ContactItem> contacts;
  final bool showChevron;
  final Set<int>? selected;
  final void Function(int)? onToggle;
  final void Function(ContactItem)? onContactTap;

  const ContactsCard({
    super.key,
    required this.contacts,
    this.showChevron = true,
    this.selected,
    this.onToggle,
    this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Column(
        children: contacts.asMap().entries.map((e) {
          final i = e.key;
          final c = e.value;
          return Padding(
            padding: EdgeInsets.zero,
            child: ContactTile(
              contact: c,
              showDivider: i != 0,
              showChevron: showChevron && selected == null,
              isSelected: selected?.contains(i) ?? false,
              hasCheckbox: selected != null,
              onTap: onContactTap != null
                  ? () => onContactTap!(c)
                  : () => onToggle?.call(i),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Contact tile

class ContactTile extends StatelessWidget {
  final ContactItem contact;
  final bool showDivider;
  final bool showChevron;
  final bool isSelected;
  final bool hasCheckbox;
  final VoidCallback? onTap;

  const ContactTile({
    super.key,
    required this.contact,
    this.showDivider = false,
    this.showChevron = true,
    this.isSelected = false,
    this.hasCheckbox = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(top: BorderSide(color: Color(0xFFEEEBF4)))
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar with optional online dot
            Stack(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEFEDF2),
                    border: Border.all(color: const Color(0x1A3A1B5E), width: 2),
                    image: contact.avatar != null
                        ? DecorationImage(
                            image: AssetImage(contact.avatar!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: contact.avatar == null
                      ? const Icon(Icons.person, color: Colors.white, size: 20)
                      : null,
                ),
                if (contact.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF401E66),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // Name + role
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF1D1B1F),
                    ),
                  ),
                  Text(
                    contact.role,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: contact.isRecruiter
                          ? const Color(0xFF401E66)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            // Trailing: chevron OR checkbox
            if (hasCheckbox)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 17,
                  height: 17,
                  child: Center(
                    child: Container(
                      width: 17,
                      height: 17,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF401E66), width: 1.5),
                        borderRadius: BorderRadius.circular(4),
                        color: isSelected ? const Color(0xFF401E66) : Colors.transparent,
                      ),
                      alignment: Alignment.center,
                      child: isSelected
                          ? const Icon(Icons.check, size: 12, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
              )
            else if (showChevron)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.chevron_right, size: 22, color: Color(0xFF401E66)),
              ),
          ],
        ),
      ),
    );
  }
}

// Job group card (annonce header + recruiter tile)

class JobGroupCard extends StatelessWidget {
  final JobGroup group;
  final bool showChevron;
  final bool hasCheckbox;
  final bool isSelected;
  final VoidCallback? onToggle;
  final void Function(ContactItem)? onContactTap;

  const JobGroupCard({
    super.key,
    required this.group,
    this.showChevron = true,
    this.hasCheckbox = false,
    this.isSelected = false,
    this.onToggle,
    this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEEBF4), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Job header row
          Container(
            height: 66,
            color: const Color(0xFFEFEDF2),
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
                    ],
                    image: group.jobImage != null
                        ? DecorationImage(
                            image: AssetImage(group.jobImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      group.jobTitle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFF1D1B1F),
                      ),
                    ),
                    Text(
                      group.company,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Recruiter tile
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 6),
            child: ContactTile(
              contact: group.recruiter,
              showDivider: true,
              showChevron: showChevron && !hasCheckbox,
              hasCheckbox: hasCheckbox,
              isSelected: isSelected,
              onTap: onContactTap != null
                  ? () => onContactTap!(group.recruiter)
                  : onToggle,
            ),
          ),
        ],
      ),
    );
  }
}

// Create group button

class CreateGroupButton extends StatelessWidget {
  final VoidCallback onTap;
  const CreateGroupButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 74,
        decoration: BoxDecoration(
          color: const Color(0xFFEFEDF2),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF401E66),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.group_add_outlined, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'créer un nouveau groupe',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF1F1D1D),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'échangez avec plusieurs personnes',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF1F1D1D),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFF401E66)),
          ],
        ),
      ),
    );
  }
}
