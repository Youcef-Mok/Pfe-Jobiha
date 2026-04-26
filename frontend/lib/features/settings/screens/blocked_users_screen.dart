import 'package:flutter/material.dart';
import 'package:job_app/core/api/api_client.dart';
import 'package:job_app/core/api/api_endpoints.dart';
import 'package:job_app/core/theme/app_theme.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  static const _purple = Color(0xFF401E66);
  static const _bg = Color(0xFFF6F3F8);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.blockedUsers);
      final List data = response.data as List;
      setState(() => _users = data.cast<Map<String, dynamic>>());
    } catch (_) {
      // backend not ready yet — show empty state
      setState(() => _users = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _unblock(String userId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Débloquer ?',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text('Voulez-vous débloquer $name ?',
            style: const TextStyle(fontSize: 13, color: Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Débloquer',
                style: TextStyle(color: _purple, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // TODO: await ApiClient.instance.delete('${ApiEndpoints.blockedUsers}/$userId');
    setState(() => _users.removeWhere((u) => u['id'].toString() == userId));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name a été débloqué.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Text('Comptes bloqués',
            style: AppTextStyles.heading1.copyWith(fontSize: 18)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _purple))
          : _users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.block, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('Aucun compte bloqué',
                          style: AppTextStyles.heading3
                              .copyWith(color: AppColors.slate600)),
                      const SizedBox(height: 8),
                      Text('Les comptes que vous bloquez apparaîtront ici.',
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    final name =
                        '${user['prenom'] ?? ''} ${user['nom'] ?? ''}'.trim();
                    final id = user['id'].toString();
                    final avatar = user['avatar'];

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: const Color(0xFFCDCDCD)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFFEDE9FE),
                            backgroundImage: avatar != null
                                ? NetworkImage(avatar)
                                : null,
                            child: avatar == null
                                ? Text(
                                    name.isNotEmpty
                                        ? name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                        color: _purple,
                                        fontWeight: FontWeight.w700),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(name.isNotEmpty ? name : 'Utilisateur',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                          ),
                          TextButton(
                            onPressed: () => _unblock(id, name),
                            style: TextButton.styleFrom(
                              foregroundColor: _purple,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(color: _purple),
                              ),
                            ),
                            child: const Text('Débloquer',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}