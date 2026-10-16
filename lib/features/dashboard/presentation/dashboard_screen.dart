import 'package:flutter/material.dart';
import 'package:health_ai/core/theme/app_theme.dart';
import 'package:health_ai/features/auth/data/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _facilityName = 'Nsiika Health Centre IV';

  final _authRepository = AuthRepository();
  final _firestore = FirebaseFirestore.instance;

  late Future<_DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _firstName(String? name) {
    if (name == null || name.trim().isEmpty) return 'User';
    return name.trim().split(' ').first;
  }

  Future<_DashboardData> _load() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      final todaySnap = await _firestore
          .collection('visits')
          .where('visitDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .get();

      final patientIds = <String>{};
      final alerts = <Map<String, dynamic>>[];
      int high = 0, low = 0;

      for (final doc in todaySnap.docs) {
        final data = doc.data();
        final pid = data['patientId']?.toString();
        if (pid != null) patientIds.add(pid);

        final risk = data['riskLevel']?.toString().toLowerCase() ?? '';
        if (risk == 'high' || risk == 'critical') {
          high++;
          alerts.add(data);
        } else if (risk == 'low') {
          low++;
        }
      }

      alerts.sort((a, b) {
        final ad = (a['visitDate'] as Timestamp?)?.toDate() ?? DateTime(2000);
        final bd = (b['visitDate'] as Timestamp?)?.toDate() ?? DateTime(2000);
        return bd.compareTo(ad);
      });

      return _DashboardData(
        patientsSeen: patientIds.length,
        visits: todaySnap.docs.length,
        highRisk: high,
        lowRisk: low,
        alerts: alerts.take(5).toList(),
      );
    } catch (e) {
      debugPrint('Dashboard load error: $e');
      return _DashboardData.empty();
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
      case 'excellent':
        return Colors.green;
      case 'low':
      case 'warning':
        return Colors.orange;
      case 'critical':
      case 'out':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authRepository.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: AppTheme.darkPurple,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        // Hamburger icon is added automatically because a drawer is set.
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No new notifications')),
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(user?.displayName),
            FutureBuilder<_DashboardData>(
              future: _future,
              builder: (context, snapshot) {
                final loading =
                    snapshot.connectionState == ConnectionState.waiting;
                final data = snapshot.data ?? _DashboardData.empty();

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionTitle('Today\'s overview'),
                      const SizedBox(height: 12),
                      _buildStats(data, loading),
                      const SizedBox(height: 28),
                      const _SectionTitle('Quick actions'),
                      const SizedBox(height: 12),
                      _buildQuickActions(context),
                      const SizedBox(height: 28),
                      const _SectionTitle('High risk alerts'),
                      const SizedBox(height: 12),
                      _buildAlerts(data, loading),
                      const SizedBox(height: 28),
                      const _SectionTitle('Facility status'),
                      const SizedBox(height: 12),
                      _buildFacilityStatus(),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Header ----------
  Widget _buildHeader(String? displayName) {
    final today = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      decoration: const BoxDecoration(
        color: AppTheme.darkPurple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_greeting()},',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _firstName(displayName),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          _HeaderInfo(icon: Icons.calendar_today_outlined, text: today),
          const SizedBox(height: 6),
          const _HeaderInfo(
              icon: Icons.location_on_outlined, text: _facilityName),
        ],
      ),
    );
  }

  // ---------- Stats ----------
  Widget _buildStats(_DashboardData d, bool loading) {
    String v(int n) => loading ? '–' : n.toString();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _StatCard(
          icon: Icons.people_outline,
          value: v(d.patientsSeen),
          label: 'Patients seen',
          color: AppTheme.darkPurple,
        ),
        _StatCard(
          icon: Icons.medical_services_outlined,
          value: v(d.visits),
          label: 'Visits recorded',
          color: Colors.blue[700]!,
        ),
        _StatCard(
          icon: Icons.warning_amber_rounded,
          value: v(d.highRisk),
          label: 'High risk',
          color: Colors.orange[800]!,
        ),
        _StatCard(
          icon: Icons.check_circle_outline,
          value: v(d.lowRisk),
          label: 'Low risk',
          color: Colors.green[700]!,
        ),
      ],
    );
  }

  // ---------- Quick actions ----------
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.person_add_alt_1_outlined,
            label: 'New patient',
            onTap: () => Navigator.pushNamed(context, '/new-patient'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.medical_services_outlined,
            label: 'Record visit',
            onTap: () => Navigator.pushNamed(context, '/record-visit'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.insights_outlined,
            label: 'Predictions',
            onTap: () => Navigator.pushNamed(context, '/predictions'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.groups_outlined,
            label: 'Patients',
            onTap: () => Navigator.pushNamed(context, '/patients'),
          ),
        ),
      ],
    );
  }

  // ---------- Alerts ----------
  Widget _buildAlerts(_DashboardData d, bool loading) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (d.alerts.isEmpty) {
      return const _EmptyStateCard(
        icon: Icons.check_circle_outline,
        message: 'No high risk patients today',
        color: Colors.green,
      );
    }

    return Column(
      children: d.alerts.map((data) {
        final factors = data['riskFactors'];
        final reason = factors is List && factors.isNotEmpty
            ? factors.join(', ')
            : 'No details';

        return _HighRiskCard(
          patientId: data['patientId']?.toString() ?? 'Unknown',
          riskLevel: data['riskLevel']?.toString() ?? 'high',
          reason: reason,
          visitDate: (data['visitDate'] as Timestamp?)?.toDate(),
        );
      }).toList(),
    );
  }

  // ---------- Facility ----------
  Widget _buildFacilityStatus() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection('facilityDaily')
          .doc(DateFormat('yyyy-MM-dd').format(DateTime.now()))
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _ErrorCard();
        }

        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final staffCount = data?['staffCount'] ?? 0;
        final medicineStatus =
            (data?['medicineAvailability'] ?? 'Unknown').toString();

        return _CardShell(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _StatusRow(
                icon: Icons.badge_outlined,
                label: 'Staff on duty',
                value: staffCount.toString(),
                color: Colors.green,
              ),
              const Divider(height: 24),
              _StatusRow(
                icon: Icons.medication_outlined,
                label: 'Medicine stock',
                value: medicineStatus,
                color: _statusColor(medicineStatus),
              ),
              const Divider(height: 24),
              const _StatusRow(
                icon: Icons.psychology_outlined,
                label: 'AI predictions',
                value: 'Active',
                color: AppTheme.primaryGreen,
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------- Drawer ----------
  Widget _buildDrawer(BuildContext context) {
    final user = _authRepository.currentUser;
    final name = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!
        : 'User';
    final sub = user?.email?.split('@')[0] ?? '';

    void go(String route) {
      Navigator.pop(context);
      Navigator.pushNamed(context, route);
    }

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 24,
              20,
              20,
            ),
            color: AppTheme.darkPurple,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (sub.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    _facilityName,
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              children: [
                _DrawerItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  selected: true,
                  onTap: () => Navigator.pop(context),
                ),
                _DrawerItem(
                  icon: Icons.groups_outlined,
                  label: 'All patients',
                  onTap: () => go('/patients'),
                ),
                _DrawerItem(
                  icon: Icons.person_add_alt_1_outlined,
                  label: 'New patient',
                  onTap: () => go('/new-patient'),
                ),
                _DrawerItem(
                  icon: Icons.medical_services_outlined,
                  label: 'Record visit',
                  onTap: () => go('/record-visit'),
                ),
                _DrawerItem(
                  icon: Icons.insights_outlined,
                  label: 'Predictions',
                  onTap: () => go('/predictions'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Divider(height: 1),
                ),
                _DrawerItem(
                  icon: Icons.health_and_safety_outlined,
                  label: 'Facility status',
                  onTap: () => go('/facility-status'),
                ),
                _DrawerItem(
                  icon: Icons.bar_chart_outlined,
                  label: 'Reports',
                  onTap: () => go('/reports'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Divider(height: 1),
                ),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () => go('/settings'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: _DrawerItem(
                icon: Icons.logout,
                label: 'Logout',
                color: Colors.red,
                onTap: () async {
                  await _authRepository.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// Data model
// =====================================================================

class _DashboardData {
  final int patientsSeen;
  final int visits;
  final int highRisk;
  final int lowRisk;
  final List<Map<String, dynamic>> alerts;

  const _DashboardData({
    required this.patientsSeen,
    required this.visits,
    required this.highRisk,
    required this.lowRisk,
    required this.alerts,
  });

  factory _DashboardData.empty() => const _DashboardData(
        patientsSeen: 0,
        visits: 0,
        highRisk: 0,
        lowRisk: 0,
        alerts: [],
      );
}

// =====================================================================
// Widgets
// =====================================================================

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppTheme.darkText,
      ),
    );
  }
}

class _HeaderInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HeaderInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 15),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;

  const _CardShell({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppTheme.greyText),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.darkPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.darkPurple, size: 22),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkText,
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

class _HighRiskCard extends StatelessWidget {
  final String patientId;
  final String riskLevel;
  final String reason;
  final DateTime? visitDate;

  const _HighRiskCard({
    required this.patientId,
    required this.riskLevel,
    required this.reason,
    this.visitDate,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        riskLevel.toLowerCase() == 'critical' ? Colors.red : Colors.orange;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _CardShell(
        borderColor: color.withOpacity(0.35),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.warning_amber_rounded, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patient $patientId',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    reason,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.greyText),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (visitDate != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      DateFormat('h:mm a').format(visitDate!),
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.greyText),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                riskLevel.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatusRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppTheme.greyText),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkText,
          ),
        ),
      ],
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const _EmptyStateCard({
    required this.icon,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Column(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: AppTheme.greyText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Error loading data',
              style: TextStyle(fontSize: 14, color: Colors.red[900]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? (selected ? AppTheme.darkPurple : AppTheme.darkText);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: selected ? AppTheme.darkPurple.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: c, size: 22),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: c,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}