import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF051424),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Safety & Verification Console', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.orangeAccent),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Safety verification logs updated'), backgroundColor: Color(0xFF059669)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // System Health Summary
              const Text('System Metrics & Corridor Safety', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: _buildMetricCard('Verified Users', '1,420', Icons.verified_user, const Color(0xFF059669))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildMetricCard('Escrow Volume', '৳ 2.4M', Icons.lock, Colors.amberAccent)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildMetricCard('Corridors', '8 Active', Icons.alt_route, Colors.orangeAccent)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildMetricCard('Match Rate', '94.8%', Icons.flash_on, Colors.lightBlueAccent)),
                ],
              ),
              const SizedBox(height: 24),

              // National NID Verification Audit Table
              const Text('National NID & Identity Verification Matrix', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    _buildUserAuditRow('Ahmed R. (Traveler)', 'Dhaka N3 Corridor', 'NID #882194021', 'VERIFIED ✓', const Color(0xFF059669)),
                    const Divider(color: Colors.white10, height: 1),
                    _buildUserAuditRow('Sara K. (Sender)', 'Gazipur Bypass', 'NID #991048201', 'VERIFIED ✓', const Color(0xFF059669)),
                    const Divider(color: Colors.white10, height: 1),
                    _buildUserAuditRow('Tanvir H. (Traveler)', 'Sylhet Highway N2', 'NID #102948102', 'PENDING ⏳', Colors.amber),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Safety Rules & Contraband Policy Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.shield, color: Colors.orangeAccent, size: 22),
                        SizedBox(width: 8),
                        Text('Open-Box & Contraband Shield', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'All packages undergo open-box visual inspection at handover. Prohibited items (illegal contraband, flammable substances, hazardous materials) are blocked by automated safety protocols.',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Safety Protocol Standards Enforced'), backgroundColor: Color(0xFF059669)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669).withValues(alpha: 0.2),
                        side: const BorderSide(color: Color(0xFF059669)),
                      ),
                      icon: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                      label: const Text('Enforce Strict Inspection Standards', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildUserAuditRow(String name, String route, String nid, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: statusColor.withValues(alpha: 0.15),
            child: Icon(Icons.person, color: statusColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Text('$route • $nid', style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
