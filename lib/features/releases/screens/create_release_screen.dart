import 'package:flutter/material.dart';

import '../../../data/services/auth_storage.dart';
import '../../../data/services/github_api_service.dart';

class CreateReleaseScreen extends StatefulWidget {
  final String owner;
  final String repoName;

  const CreateReleaseScreen({
    super.key,
    required this.owner,
    required this.repoName,
  });

  @override
  State<CreateReleaseScreen> createState() => _CreateReleaseScreenState();
}

class _CreateReleaseScreenState extends State<CreateReleaseScreen> {
  final _tagController = TextEditingController();
  final _nameController = TextEditingController();
  final _bodyController = TextEditingController();

  bool _draft = false;
  bool _prerelease = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _tagController.dispose();
    _nameController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final tag = _tagController.text.trim();
    if (tag.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tag name wajib diisi (contoh: v1.0.0)'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final token = await AuthStorage.getToken();
    if (token == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    final result = await GitHubApiService.createRelease(
      token,
      widget.owner,
      widget.repoName,
      tagName: tag,
      name: _nameController.text.trim(),
      body: _bodyController.text.trim(),
      draft: _draft,
      prerelease: _prerelease,
    );

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Release berhasil dibuat'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context, true);
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal bikin release. Cek tag-nya.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Release тАФ ${widget.repoName}',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF6366F1),
                      ),
                    )
                  : const Text(
                      'Publish',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6366F1),
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('Tag Name *'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _tagController,
              hint: 'v1.0.0',
              maxLines: 1,
            ),
            const SizedBox(height: 8),
            const Text(
              'Contoh: v1.0.0, v2.1.3, release-1',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              ),
            ),

            const SizedBox(height: 20),
            _buildSectionLabel('Release Title'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hint: 'Release name (opsional)',
              maxLines: 1,
            ),

            const SizedBox(height: 20),
            _buildSectionLabel('Description'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _bodyController,
              hint: 'Jelasin apa aja yang baru di release ini...',
              maxLines: 10,
            ),

            const SizedBox(height: 20),

            // Draft toggle
            _buildToggleCard(
              icon: _draft
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              title: 'Draft',
              subtitle: 'Release belum di-publish',
              value: _draft,
              onTap: () => setState(() => _draft = !_draft),
            ),
            const SizedBox(height: 10),

            // Pre-release toggle
            _buildToggleCard(
              icon: _prerelease
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              title: 'Pre-release',
              subtitle: 'Release belum stabil / beta',
              value: _prerelease,
              onTap: () => setState(() => _prerelease = !_prerelease),
            ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 18, color: Color(0xFF6366F1)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Release bakal langsung dipublish ke GitHub.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF6366F1),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: Color(0xFF111827),
          height: 1.5,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF9CA3AF),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6366F1), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}