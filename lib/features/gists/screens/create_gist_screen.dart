import 'package:flutter/material.dart';

import '../../../data/services/auth_storage.dart';
import '../../../data/services/github_api_service.dart';

class CreateGistScreen extends StatefulWidget {
  const CreateGistScreen({super.key});

  @override
  State<CreateGistScreen> createState() => _CreateGistScreenState();
}

class _CreateGistScreenState extends State<CreateGistScreen> {
  final _filenameController =
      TextEditingController(text: 'untitled.txt');
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();

  bool _isPublic = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _filenameController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final filename = _filenameController.text.trim();
    final content = _contentController.text;

    if (filename.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Filename wajib diisi'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    if (content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Content gak boleh kosong'),
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

    final result = await GitHubApiService.createGist(
      token,
      filename: filename,
      content: content,
      description: _descriptionController.text.trim(),
      public: _isPublic,
    );

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gist berhasil dibuat'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context, true);
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal bikin gist'),
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
          'New Gist',
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
            _buildLabel('Description'),
            const SizedBox(height: 8),
            _buildInput(
              controller: _descriptionController,
              hint: 'Deskripsi gist (opsional)',
              maxLines: 2,
            ),

            const SizedBox(height: 20),
            _buildLabel('Filename *'),
            const SizedBox(height: 8),
            _buildInput(
              controller: _filenameController,
              hint: 'contoh: snippet.dart',
              maxLines: 1,
            ),

            const SizedBox(height: 20),
            _buildLabel('Content *'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF30363D)),
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 15,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Color(0xFFE6EDF3),
                  height: 1.5,
                ),
                decoration: const InputDecoration(
                  hintText: '// Paste code lu di sini...',
                  hintStyle: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Color(0xFF6E7681),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Toggle public/secret
            GestureDetector(
              onTap: () => setState(() => _isPublic = !_isPublic),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isPublic
                          ? Icons.public_rounded
                          : Icons.lock_rounded,
                      color: _isPublic
                          ? const Color(0xFF10B981)
                          : const Color(0xFF6B7280),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isPublic ? 'Public Gist' : 'Secret Gist',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isPublic
                                ? 'Semua orang bisa liat'
                                : 'Cuma lu yang bisa liat',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _isPublic
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      color: const Color(0xFF6366F1),
                      size: 22,
                    ),
                  ],
                ),
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
}