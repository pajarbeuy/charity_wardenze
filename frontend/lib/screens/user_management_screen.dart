import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/providers/cfms_provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CfmsProvider>(context, listen: false).fetchUsers();
    });
  }

  void _showAddUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController(text: 'password');
    String role = 'Member';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Anggota Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
              const SizedBox(height: 12),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 12),
              TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password Initial')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: role,
                items: const [
                  DropdownMenuItem(value: 'Member', child: Text('Member')),
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                ],
                onChanged: (v) => role = v!,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('BATAL')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty) return;
              try {
                await Provider.of<CfmsProvider>(context, listen: false).createUser(nameCtrl.text, emailCtrl.text, passCtrl.text, role);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppTheme.danger));
                }
              }
            },
            child: const Text('TAMBAH'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cfms = Provider.of<CfmsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Anggota Komunitas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah Member'),
      ),
      body: RefreshIndicator(
        onRefresh: () => cfms.fetchUsers(),
        child: cfms.users.isEmpty
            ? const Center(child: Text('Belum ada pengguna', style: TextStyle(color: Color(0xFF94A3B8))))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cfms.users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final u = cfms.users[index];

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: u.isAdmin ? AppTheme.primary.withOpacity(0.15) : const Color(0xFFE2E8F0),
                        child: Icon(u.isAdmin ? Icons.admin_panel_settings : Icons.person, color: u.isAdmin ? AppTheme.primary : const Color(0xFF334155)),
                      ),
                      title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${u.email} | Role: ${u.roleName}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: u.isAdmin ? AppTheme.primary.withOpacity(0.1) : AppTheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          u.roleName,
                          style: TextStyle(color: u.isAdmin ? AppTheme.primary : AppTheme.secondary, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
