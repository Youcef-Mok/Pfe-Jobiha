import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/messaging/data/providers/messaging_provider.dart';
import 'package:job_app/features/messaging/data/providers/contacts_provider.dart';
import 'package:job_app/features/messaging/widgets/contact_widgets.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  String _groupName = '';
  bool _editingName = false;
  late final TextEditingController _nameController;
  late final FocusNode _nameFocusNode;
  final Set<int> _selectedSuggestions = {};
  final Set<int> _selectedRecruiters = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameFocusNode = FocusNode();
    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus) {
        setState(() {
          _groupName = _nameController.text.trim();
          _editingName = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  int get _totalSelected => _selectedSuggestions.length + _selectedRecruiters.length;

  // All selected contacts mapped to their ContactItem
  List<_SelectedEntry> _selectedEntries(ContactsData contactsData) {
    final result = <_SelectedEntry>[];
    for (final i in _selectedSuggestions) {
      if (i < contactsData.suggestions.length) {
        result.add(_SelectedEntry(contact: contactsData.suggestions[i], isSuggestion: true, index: i));
      }
    }
    for (final i in _selectedRecruiters) {
      if (i < contactsData.recruiters.length) {
        result.add(_SelectedEntry(contact: contactsData.recruiters[i], isSuggestion: false, index: i));
      }
    }
    return result;
  }

  void _removeSelected(_SelectedEntry entry) {
    setState(() {
      if (entry.isSuggestion) {
        _selectedSuggestions.remove(entry.index);
      } else {
        _selectedRecruiters.remove(entry.index);
      }
    });
  }

  Future<void> _createGroup(ContactsData contactsData) async {
    if (_totalSelected < 1) return;
    final entries = _selectedEntries(contactsData);
    final names = entries.map((e) => e.contact.name).toList();
    final avatars = entries.map((e) => e.contact.avatar).toList();
    await ref
        .read(messagingControllerProvider.notifier)
        .createGroup(_groupName, names, avatars);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 64,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1D1B1F)),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'créer un groupe',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Color(0xFF1D1B1F),
                      ),
                    ),
                  ),
                  contactsAsync.when(
                    data: (contactsData) => GestureDetector(
                      onTap: () => _createGroup(contactsData),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: _totalSelected > 0
                              ? const Color(0xFF401E66)
                              : const Color(0xFFEFEDF2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _totalSelected > 0
                              ? 'créer ($_totalSelected)'
                              : 'créer',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: _totalSelected > 0
                                ? Colors.white
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: contactsAsync.when(
                data: (contactsData) {
                  final entries = _selectedEntries(contactsData);
                  
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MessageSearchBar(),
                        const SizedBox(height: 12),

                        // Group name (inline edit)
                        Center(
                          child: _editingName
                              ? IntrinsicWidth(
                                  child: TextField(
                                    controller: _nameController,
                                    focusNode: _nameFocusNode,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Color(0xFF1D1B1F),
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'nom du groupe...',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Color(0xFF401E66),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                    ),
                                    onSubmitted: (val) {
                                      setState(() {
                                        _groupName = val.trim();
                                        _editingName = false;
                                      });
                                    },
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    _nameController.text = _groupName;
                                    setState(() => _editingName = true);
                                    Future.microtask(() => _nameFocusNode.requestFocus());
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _groupName.isEmpty ? Icons.edit_outlined : Icons.edit,
                                        size: 16,
                                        color: const Color(0xFF401E66),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _groupName.isEmpty ? 'choisir nom de groupe' : _groupName,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: _groupName.isEmpty
                                              ? const Color(0xFF401E66)
                                              : const Color(0xFF1D1B1F),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        const SizedBox(height: 12),

                        // Selected people bar
                        if (entries.isNotEmpty) ...[
                          SizedBox(
                            height: 80,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              itemCount: entries.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (ctx, i) => _SelectedPersonChip(
                                entry: entries[i],
                                onRemove: () => _removeSelected(entries[i]),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],

                        // Suggestions
                        if (contactsData.suggestions.isNotEmpty) ...[
                          const MessageSectionHeader(title: 'suggestions', action: 'voir tous'),
                          const SizedBox(height: 7),
                          ContactsCard(
                            contacts: contactsData.suggestions,
                            showChevron: false,
                            selected: _selectedSuggestions,
                            onToggle: (i) => setState(() {
                              _selectedSuggestions.contains(i)
                                  ? _selectedSuggestions.remove(i)
                                  : _selectedSuggestions.add(i);
                            }),
                          ),
                          const SizedBox(height: 10),
                        ],

                        // Recruiters
                        if (contactsData.recruiters.isNotEmpty) ...[
                          const MessageSectionHeader(title: 'recruteurs'),
                          const SizedBox(height: 7),
                          ContactsCard(
                            contacts: contactsData.recruiters,
                            showChevron: false,
                            selected: _selectedRecruiters,
                            onToggle: (i) => setState(() {
                              _selectedRecruiters.contains(i)
                                  ? _selectedRecruiters.remove(i)
                                  : _selectedRecruiters.add(i);
                            }),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Erreur de chargement des contacts',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF1D1B1F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Color(0xFF64748B),
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
      ),
    );
  }

}

// Helper to track a selected contact with its source
class _SelectedEntry {
  final ContactItem contact;
  final bool isSuggestion;
  final int index;
  const _SelectedEntry({required this.contact, required this.isSuggestion, required this.index});
}

// Chip showing avatar + first name + remove button
class _SelectedPersonChip extends StatelessWidget {
  final _SelectedEntry entry;
  final VoidCallback onRemove;

  const _SelectedPersonChip({required this.entry, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final firstName = entry.contact.name.split(' ').first;

    return SizedBox(
      width: 56,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEFEDF2),
                  border: Border.all(color: const Color(0x1A3A1B5E), width: 2),
                  image: entry.contact.avatar != null
                      ? DecorationImage(
                          image: AssetImage(entry.contact.avatar!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: entry.contact.avatar == null
                    ? const Icon(Icons.person, color: Colors.grey, size: 20)
                    : null,
              ),
              // Remove button
              Positioned(
                top: -4,
                right: -4,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFF401E66),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 11, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            firstName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 11,
              color: Color(0xFF1D1B1F),
            ),
          ),
        ],
      ),
    );
  }
}
