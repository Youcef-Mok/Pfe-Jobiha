import 'package:flutter/material.dart';
import 'package:job_app/core/theme/app_theme.dart';
import 'package:job_app/features/messaging/domain/message_entity.dart';
import 'package:job_app/features/messaging/screens/create_group_screen.dart';
import 'package:job_app/features/messaging/screens/private_message_screen.dart';
import 'package:job_app/features/messaging/widgets/contact_widgets.dart';

class NewMessageScreen extends StatefulWidget {
  final bool initialSearchMode;
  const NewMessageScreen({super.key, this.initialSearchMode = false});

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  bool _searchMode = false;
  bool _isGroupedByAnnonce = false;
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  static const _recents = [
    ContactItem(name: 'Camille Martin', role: 'Pizzaiolo', avatar: 'assets/images/pdp_1.png', isOnline: true),
    ContactItem(name: 'Marc Dubois', role: 'Recruteur chez Le Petit Bistro', avatar: 'assets/images/pdp_2.png', isOnline: false, isRecruiter: true),
    ContactItem(name: 'Leila Mansouri', role: 'Recruteur chez FoodGroup', avatar: 'assets/images/pdp_3.png', isOnline: true, isRecruiter: true),
  ];

  static const _suggestions = [
    ContactItem(name: 'Yasmine Bensalem', role: 'Étudiante', avatar: 'assets/images/pdp_4.png', isOnline: false),
    ContactItem(name: 'Karim Benali', role: 'Recruteur chez Coffee Corner', avatar: 'assets/images/pdp_1.png', isOnline: true, isRecruiter: true),
    ContactItem(name: 'Sophie Laurent', role: 'Recruteur chez FoodGroup', avatar: 'assets/images/pdp_2.png', isOnline: false, isRecruiter: true),
  ];

  static const _recruitersFlat = [
    ContactItem(name: 'Camille Martin', role: 'Recruteur chez Le Petit Bistro', avatar: 'assets/images/pdp_1.png', isOnline: true, isRecruiter: true),
    ContactItem(name: 'Marc Dubois', role: 'Recruteur chez Le Petit Bistro', avatar: 'assets/images/pdp_2.png', isOnline: false, isRecruiter: true),
    ContactItem(name: 'Leila Mansouri', role: 'Recruteur chez FoodGroup', avatar: 'assets/images/pdp_4.png', isOnline: true, isRecruiter: true),
  ];

  static const _recruitersGrouped = [
    JobGroup(
      jobTitle: 'Serveur de café',
      company: 'Le Petit Bistro',
      jobImage: 'assets/images/imageannonc(1).jpg',
      recruiter: ContactItem(name: 'Camille Martin', role: 'Recruteur chez Le Petit Bistro', avatar: 'assets/images/pdp_1.png', isOnline: true, isRecruiter: true),
    ),
    JobGroup(
      jobTitle: 'Barista',
      company: 'Coffee Corner',
      jobImage: 'assets/images/imageannonc(2).jpg',
      recruiter: ContactItem(name: 'Marc Dubois', role: 'Recruteur chez Coffee Corner', avatar: 'assets/images/pdp_2.png', isOnline: false, isRecruiter: true),
    ),
  ];

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

  void _openConversation(ContactItem contact) {
    final conv = ConversationEntity(
      id: 'new_${contact.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}',
      contactName: contact.name,
      contactRole: contact.role,
      contactAvatar: contact.avatar,
      isOnline: contact.isOnline,
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      isUnread: false,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PrivateMessageScreen(conversation: conv)),
    );
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header â€” changes based on search mode
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _searchMode ? _buildSearchBody() : _buildNormalBody(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNormalBody() {
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

      // suggestions
      const MessageSectionHeader(title: 'suggestions', action: 'voir tous'),
      const SizedBox(height: 7),
      ContactsCard(contacts: _suggestions, onContactTap: _openConversation),
      const SizedBox(height: 16),

      // Recruiters
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const MessageSectionHeader(title: 'recruteurs'),
          SortByAnnonceButton(
            isActive: _isGroupedByAnnonce,
            onTap: () => setState(() => _isGroupedByAnnonce = !_isGroupedByAnnonce),
          ),
        ],
      ),
      const SizedBox(height: 7),

      if (_isGroupedByAnnonce)
        ..._recruitersGrouped.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: JobGroupCard(group: g, onContactTap: _openConversation),
            ))
      else
        ContactsCard(contacts: _recruitersFlat, onContactTap: _openConversation),

      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildSearchBody() {
    final recents = _filterContacts(_recents);
    final suggestions = _filterContacts(_suggestions);
    final recruiters = _filterContacts(_recruitersFlat);
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
