import 'package:flutter/material.dart';

import '../../../data/services/auth_storage.dart';
import '../../../data/services/github_api_service.dart';

class CreateRepoScreen extends StatefulWidget {
  const CreateRepoScreen({super.key});

  @override
  State<CreateRepoScreen> createState() => _CreateRepoScreenState();
}

class _CreateRepoScreenState extends State<CreateRepoScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _homepageController = TextEditingController();

  bool _isPrivate = false;
  bool _autoInit = true;
  bool _hasIssues = true;
  bool _hasProjects = true;
  bool _hasWiki = false;

  String _gitignore = '';
  String _license = '';

  bool _isSubmitting = false;

  static const List<String> _gitignoreOptions = [
    '',
    'Android',
    'Dart',
    'Flutter',
    'Node',
    'Python',
    'Java',
    'Kotlin',
    'Swift',
    'Go',
    'Rust',
    'C++',
    'Ruby',
    'PHP',
    'Unity',
    'VisualStudio',
  ];

  static const List<String> _licenseOptions = [
    '',
    'mit',
    'apache-2.0',
    'gpl-3.0',
    'bsd-3-clause',
    'mpl-2.0',
    'unlicense',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _homepageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama repo wajib diisi'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    // Validasi: nama repo cuma boleh huruf, angka, -, _, .
    final validName = RegExp(r'^[a-zA-Z0-9._-]+$');
    if (!validName.hasMatch(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Nama repo cuma boleh huruf, angka, dash, underscore, dot'),
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

    final result = await GitHubApiService.createRepo(
      token,
      name: name,
      description: _descriptionController.text.trim(),
      private: _isPrivate,
      autoInit: _autoInit,
      hasIssues: _hasIssues,
      hasProjects: _hasProjects,
      hasWiki: _hasWiki,
      gitignoreTemplate: _gitignore,
      licenseTemplate: _license,
      homepage: _homepageController.text.trim(),
    );

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Repo "${result['name']}" berhasil dibuat'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      Navigator.pop(context, result);
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal bikin repo. Cek nama repo.'),
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
        title: const Text(
          'New Repository',
          style: TextStyle(
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
                      'Create',
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
            // Nama repo
            _buildLabel('Repository Name *'),
            const SizedBox(height: 8),
            _buildInput(
              controller: _nameController,
              hint: 'nama-repo-lu',
              icon: Icons.folder_outlined,
            ),
            const SizedBox(height: 6),
            const Text(
              'Gunakan huruf, angka, dash, underscore, atau dot.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              ),
            ),

            const SizedBox(height: 20),

            // Deskripsi
            _buildLabel('Description'),
            const SizedBox(height: 8),
            _buildInput(
              controller: _descriptionController,
              hint: 'Deskripsi repo (opsional)',
              icon: Icons.info_outline_rounded,
              maxLines: 3,
            ),

            const SizedBox(height: 20),

            // Homepage
            _buildLabel('Website'),
            const SizedBox(height: 8),
            _buildInput(
              controller: _homepageController,
              hint: 'https://website-lu.com',
              icon: Icons.link_rounded,
              keyboard: TextInputType.url,
            ),

            const SizedBox(height: 20),

            // Public/Private toggle
            _buildToggleCard(
              icon: _isPrivate
                  ? Icons.lock_rounded
                  : Icons.public_rounded,
              title: _isPrivate ? 'Private Repository' : 'Public Repository',
              subtitle: _isPrivate
                  ? 'Cuma lu yang bisa liat'
                  : 'Semua orang bisa liat',
              color: _isPrivate
                  ? const Color(0xFF6B7280)
                  : const Color(0xFF10B981),
              onTap: () => setState(() => _isPrivate = !_isPrivate),
              isActive: true,
            ),

            const SizedBox(height: 20),

            // Initialize with README
            _buildToggleCard(
              icon: Icons.description_outlined,
              title: 'Initialize with README',
              subtitle: 'Bikin file README.md otomatis',
              color: const Color(0xFF6366F1),
              onTap: () => setState(() => _autoInit = !_autoInit),
              isActive: _autoInit,
            ),

            const SizedBox(height: 20),

            // Advanced section
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Advanced Options',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // .gitignore
                  _buildLabel('Gitignore Template'),
                  const SizedBox(height: 6),
                  _buildDropdown(
                    value: _gitignore,
                    hint: 'Pilih template',
                    options: _gitignoreOptions,
                    onChanged: (v) => setState(() => _gitignore = v ?? ''),
                  ),

                  const SizedBox(height: 14),

                  // License
                  _buildLabel('License'),
                  const SizedBox(height: 6),
                  _buildDropdown(
                    value: _license,
                    hint: 'Pilih license',
                    options: _licenseOptions,
                    onChanged: (v) => setState(() => _license = v ?? ''),
                  ),

                  const SizedBox(height: 14),

                  const Divider(),
                  const SizedBox(height: 6),

                  // Features checkboxes
                  _buildCheckbox(
                    label: 'Issues',
                    value: _hasIssues,
                    onChanged: (v) => setState(() => _hasIssues = v),
                  ),
                  _buildCheckbox(
                    label: 'Projects',
                    value: _hasProjects,
                    onChanged: (v) => setState(() => _hasProjects = v),
                  ),
                  _buildCheckbox(
                    label: 'Wiki',
                    value: _hasWiki,
                    onChanged: (v) => setState(() => _hasWiki = v),
                  ),
                ],
              ),
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
                      'Repo bakal langsung dibuat di akun GitHub lu.',
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

  Widget _buildLabel(String text) {
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

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
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
        keyboardType: keyboard,
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
          prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String hint,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.isEmpty ? null : value,
          hint: Text(
            hint,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Color(0xFF9CA3AF),
            ),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF6B7280)),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Color(0xFF111827),
            fontWeight: FontWeight.w600,
          ),
          items: options.map<DropdownMenuItem<String>>((String opt) {
            return DropdownMenuItem<String>(
              value: opt,
              child: Text(
                opt.isEmpty ? 'None' : opt,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Color(0xFF111827),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildToggleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? color.withValues(alpha: 0.5)
                : const Color(0xFFE5E7EB),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
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
            if (isActive)
              Icon(Icons.check_circle_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              value
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              color: const Color(0xFF6366F1),
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}