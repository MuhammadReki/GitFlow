import 'package:flutter/material.dart';

import '../../../data/models/github_user.dart';
import '../../../data/services/auth_storage.dart';
import '../../../data/services/github_api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final GitHubUser user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _companyController;
  late final TextEditingController _locationController;
  late final TextEditingController _blogController;
  late final TextEditingController _twitterController;

  String _hireable = '';

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name ?? '');
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _companyController =
        TextEditingController(text: widget.user.company ?? '');
    _locationController =
        TextEditingController(text: widget.user.location ?? '');
    _blogController = TextEditingController(text: widget.user.blog ?? '');
    _twitterController =
        TextEditingController(text: widget.user.twitterUsername ?? '');
    _hireable = widget.user.hireable ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _blogController.dispose();
    _twitterController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSubmitting = true);

    final token = await AuthStorage.getToken();
    if (token == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    final result = await GitHubApiService.updateProfile(
      token,
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      company: _companyController.text.trim(),
      location: _locationController.text.trim(),
      blog: _blogController.text.trim(),
      twitterUsername: _twitterController.text.trim(),
      hireable: _hireable,
    );

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile berhasil diupdate'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context, true);
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal update profile'),
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
          'Edit Profile',
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
              onPressed: _isSubmitting ? null : _save,
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
                      'Save',
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
            // Avatar preview
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFF6366F1), width: 3),
                  image: widget.user.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(widget.user.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.user.avatarUrl == null
                    ? const Icon(Icons.person,
                        color: Color(0xFF6366F1), size: 45)
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '@${widget.user.login}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),

            const SizedBox(height: 24),

            _buildField(
              label: 'Name',
              controller: _nameController,
              hint: 'Nama lengkap lu',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 16),

            _buildField(
              label: 'Bio',
              controller: _bioController,
              hint: 'Ceritain tentang diri lu...',
              icon: Icons.info_outline_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            _buildField(
              label: 'Company',
              controller: _companyController,
              hint: '@namacompany',
              icon: Icons.business_rounded,
            ),
            const SizedBox(height: 16),

            _buildField(
              label: 'Location',
              controller: _locationController,
              hint: 'Jakarta, Indonesia',
              icon: Icons.location_on_rounded,
            ),
            const SizedBox(height: 16),

            _buildField(
              label: 'Website',
              controller: _blogController,
              hint: 'https://website-lu.com',
              icon: Icons.link_rounded,
              keyboard: TextInputType.url,
            ),
            const SizedBox(height: 16),

            _buildField(
              label: 'Twitter Username',
              controller: _twitterController,
              hint: 'username (tanpa @)',
              icon: Icons.alternate_email_rounded,
            ),
            const SizedBox(height: 16),

            // Hireable toggle
            const Text(
              'Hireable',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  _buildHireableOption('', 'Tidak diset'),
                  _buildHireableOption('true', 'Ya'),
                  _buildHireableOption('false', 'Tidak'),
                ],
              ),
            ),

            const SizedBox(height: 28),
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
                      'Perubahan bakal langsung disimpen ke GitHub.',
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

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
              prefixIcon: Icon(icon,
                  color: const Color(0xFF9CA3AF), size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHireableOption(String value, String label) {
    final isSelected = _hireable == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _hireable = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF6366F1).withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ),
    );
  }
}