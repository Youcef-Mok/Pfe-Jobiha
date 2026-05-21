import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/messaging/screens/create_group_screen.dart';
import 'package:job_app/features/messaging/screens/private_message_screen.dart';
import 'package:job_app/features/messaging/widgets/contact_widgets.dart';
import 'package:job_app/features/messaging/data/providers/contacts_provider.dart';
import 'package:job_app/features/messaging/data/providers/messaging_provider.dart';

class NewMessageScreen extends ConsumerStatefulWidget {
  final bool initialSearchMode;
  const NewMessageScreen({super.key, this.initialSearchMode = false});

  @override
  ConsumerState<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends ConsumerState<NewMessageScreen> {
  bool _searchMode = false;
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchMode = widget.initialSearchMode;
    if (_searchMode) {
      Future.microtask(() => _focusNode.requestFocus());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _enterSearch() {
    setState(() => _searchMode = true);
    Future.microtask(() => _focusNode.requestFocus());
  }

  void _exitSearch() {
    _focusNode.unfocus();
    setState(() {
      _searchMode = false;
      _searchController.clear();
    });
  }

  void _openConversation(ContactItem contact) async {
    try {
      // Use the real API to get or create a conversation with this contact
      final conv = await ref.read(messagingControllerProvider.notifier).getOrCreateConversation(
        contactName: contact.name,
        contactRole: contact.role,
        contactAvatar: contact.avatar,
      );
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PrivateMessageScreen(conversation: conv)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ouverture de la conversation: $e')),
        );
      }
    }
  }

  List<ContactItem> _filterContacts(List<ContactItem> source) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return source;
    return source
        .where((c) =>
            c.name.toLowerCase().contains(q) || c.role.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header — changes based on search mode
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
                    onTap: _searchMode ? _exitSearch : () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1D1B1F)),
                    ),
                  ),
                  if (_searchMode) ...[
                    const SizedBox(width: 8),
                    // Search bar replaces title in header
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFEDF2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            const Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _focusNode,
                                onChanged: (_) => setState(() {}),
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Color(0xFF1D1B1F),
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'search contacts or messages',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(width: 16),
                    const Text(
                      'nouveau message',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Color(0xFF1D1B1F),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Body
            Expanded(
              child: contactsAsync.when(
                data: (contactsData) => SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _searchMode 
                      ? _buildSearchBody(contactsData) 
                      : _buildNormalBody(contactsData),
                  ),
                ),
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

  List<Widget> _buildNormalBody(ContactsData contactsData) {
    return [
      // Tappable search bar
      GestureDetector(
        onTap: _enterSearch,
        child: const MessageSearchBar(),
      ),
      const SizedBox(height: 12),

      // Create group button
      CreateGroupButton(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
        ),
      ),
      const SizedBox(height: 16),

      // Recents (from conversations)
      if (contactsData.recents.isNotEmpty) ...[
        const MessageSectionHeader(title: 'recents', action: 'voir tous'),
        const SizedBox(height: 7),
        ContactsCard(contacts: contactsData.recents, onContactTap: _openConversation),
        const SizedBox(height: 16),
      ],

      // Suggestions (empty for now - no backend support)
      if (contactsData.suggestions.isNotEmpty) ...[
        const MessageSectionHeader(title: 'suggestions', action: 'voir tous'),
        const SizedBox(height: 7),
        ContactsCard(contacts: contactsData.suggestions, onContactTap: _openConversation),
        const SizedBox(height: 16),
      ],

      // Recruiters (from published jobs)
      if (contactsData.recruiters.isNotEmpty) ...[
        const MessageSectionHeader(title: 'recruteurs'),
        const SizedBox(height: 7),
        ContactsCard(contacts: contactsData.recruiters, onContactTap: _openConversation),
        const SizedBox(height: 16),
      ],
    ];
  }

  List<Widget> _buildSearchBody(ContactsData contactsData) {
    final recents = _filterContacts(contactsData.recents);
    final suggestions = _filterContacts(contactsData.suggestions);
    final recruiters = _filterContacts(contactsData.recruiters);
    final allCount = recents.length + suggestions.length + recruiters.length;

    if (allCount == 0) {
      return const [
        SizedBox(height: 28),
        Center(
          child: Text(
            'aucun résultat',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        SizedBox(height: 16),
      ];
    }

    return [
      if (recents.isNotEmpty) ...[
        const MessageSectionHeader(title: 'recents', action: 'voir tous'),
        const SizedBox(height: 7),
        ContactsCard(contacts: recents, onContactTap: _openConversation),
        const SizedBox(height: 16),
      ],
      if (suggestions.isNotEmpty) ...[
        const MessageSectionHeader(title: 'suggestions'),
        const SizedBox(height: 7),
        ContactsCard(contacts: suggestions, onContactTap: _openConversation),
        const SizedBox(height: 16),
      ],
      if (recruiters.isNotEmpty) ...[
        const MessageSectionHeader(title: 'recruteurs'),
        const SizedBox(height: 7),
        ContactsCard(contacts: recruiters, onContactTap: _openConversation),
        const SizedBox(height: 16),
      ],
    ];
  }
}
