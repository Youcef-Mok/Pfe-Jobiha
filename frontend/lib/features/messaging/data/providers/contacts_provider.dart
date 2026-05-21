import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_app/features/messaging/data/providers/messaging_provider.dart';
import 'package:job_app/features/messaging/widgets/contact_widgets.dart';
import 'package:job_app/features/auth/data/users_repository.dart';
import 'package:job_app/features/auth/providers/auth_providers.dart';

final usersRepositoryProvider = Provider((ref) => UsersRepository());

/// Provider that aggregates contacts from multiple sources:
/// - Recent conversations
/// - All users (suggestions)
/// - Recruiters (users with role='recruteur')
final contactsProvider = FutureProvider<ContactsData>((ref) async {
  // Get conversations from messaging repository
  final messagingRepository = ref.watch(messagingRepositoryProvider);
  final conversations = await messagingRepository.getConversations();
  
  // Get users repository
  final usersRepository = ref.watch(usersRepositoryProvider);
  
  // Get current user ID to exclude from lists
  final authState = ref.watch(authProvider);
  final currentUserId = authState.userId;
  
  final recents = <ContactItem>[];
  final suggestions = <ContactItem>[];
  final recruiters = <ContactItem>[];
  
  // Extract contacts from recent conversations (non-group, non-invitation)
  for (final conv in conversations) {
    if (!conv.isGroup && !conv.isInvitation) {
      recents.add(ContactItem(
        name: conv.contactName,
        role: conv.contactRole,
        avatar: conv.contactAvatar,
        isOnline: conv.isOnline,
        isRecruiter: conv.contactRole == 'recruteur',
      ));
    }
  }
  
  // Fetch all users for suggestions (exclude current user)
  try {
    final allUsers = await usersRepository.getUsers();
    for (final user in allUsers) {
      if (currentUserId != null && user.id == currentUserId) continue;
      
      suggestions.add(ContactItem(
        name: '${user.prenom} ${user.nom}',
        role: user.role ?? '',
        avatar: user.avatarUrl,
        isOnline: false,
        isRecruiter: user.role == 'recruteur',
      ));
    }
  } catch (e) {
    // If fetching all users fails, suggestions remain empty
  }
  
  // Fetch recruiters (exclude current user)
  try {
    final recruiterUsers = await usersRepository.getUsers(role: 'recruteur');
    for (final user in recruiterUsers) {
      if (currentUserId != null && user.id == currentUserId) continue;
      
      recruiters.add(ContactItem(
        name: '${user.prenom} ${user.nom}',
        role: user.role ?? 'Recruteur',
        avatar: user.avatarUrl,
        isOnline: false,
        isRecruiter: true,
      ));
    }
  } catch (e) {
    // If fetching recruiters fails, recruiters remain empty
  }
  
  return ContactsData(
    recents: recents,
    suggestions: suggestions,
    recruiters: recruiters,
  );
});

class ContactsData {
  final List<ContactItem> recents;
  final List<ContactItem> suggestions;
  final List<ContactItem> recruiters;
  
  const ContactsData({
    required this.recents,
    required this.suggestions,
    required this.recruiters,
  });
  
  List<ContactItem> get all => [...recents, ...suggestions, ...recruiters];
}
