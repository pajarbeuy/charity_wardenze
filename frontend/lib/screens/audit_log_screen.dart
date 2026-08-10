import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/cfms_provider.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CfmsProvider>(context, listen: false).fetchAuditLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cfms = Provider.of<CfmsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Audit Activity Log')),
      body: RefreshIndicator(
        onRefresh: () => cfms.fetchAuditLogs(),
        child: cfms.auditLogs.isEmpty
            ? const Center(child: Text('Belum ada catatan aktivitas', style: TextStyle(color: Color(0xFF94A3B8))))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cfms.auditLogs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final log = cfms.auditLogs[index];

                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFF3E8FF),
                        child: Icon(Icons.security, color: Colors.purple),
                      ),
                      title: Text(log.action, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Pengguna: ${log.user?.name ?? "System"} | IP: ${log.ipAddress ?? "-"}'),
                      trailing: Text(
                        log.createdAt.split('T')[0],
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
