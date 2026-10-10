import 'package:flutter/material.dart';

import '../../../data/models/github_branch.dart';
import '../../../data/services/auth_storage.dart';
import '../../../data/services/github_api_service.dart';

class CreatePRScreen extends StatefulWidget {
  final String owner;
  final String repoName;

  const CreatePRScreen({
    super.key,
    required this.owner,
    required this.repoName,
  });

  @override
  State<CreatePRScreen> createState() => _CreatePRScreenState();
}

class _CreatePRScreenState extends State<CreatePRScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  List<GitHubBranch> _branches = [];
  String? _headBranch;
  String? _baseBranch;
  bool _isLoadingBranches = true;
  bool _isSubmitting = false;
  bool _draft = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _loadBranches() async {
    _token = await AuthStorage.getToken();
    if (_token == null) return;

    final branches = await GitHubApiService.getBranches(
      _token!,
      widget.owner,
      widget.repoName,
    );

    if (!mounted) return;
    setState(() {
      _branches = branches;
      _isLoadingBranches = false;
      if (branches.isNotEmpty) {
        _baseBranch = branches.first.name;
        if (branches.length > 1) {
          _headBranch = branches[1].name;
        }
      }
    });
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul PR harus diisi'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    if (_headBranch == null || _baseBranch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih branch head dan base'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    if (_headBranch == _baseBranch) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Head dan base branch gak boleh sama'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await GitHubApiService.createPR(
      _token!,
      widget.owner,
      widget.repoName,
      title: title,
      head: _headBranch!,
      base: _baseBranch!,
      body: _bodyController.text.trim(),
      draft: _draft,
    );

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PR berhasil dibuat #${result['number']}'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      Navigator.pop(context, true);
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal bikin PR. Cek branch-nya.'),
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
          'New PR тАФ ${widget.repoName}',
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
                        color: Color(0xFF8B5CF6),
                      ),
                    )
                  : const Text(
                      'Create',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: _isLoadingBranches
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Branch',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: [
                        _buildBranchRow(
                          label: 'base',
                          value: _baseBranch,
                          onChanged: (v) =>
                              setState(() => _baseBranch = v),
                        ),
                        const Divider(height: 20),
                        _buildBranchRow(
                          label: 'head',
                          value: _headBranch,
                          onChanged: (v) =>
                              setState(() => _headBranch = v),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Title',
                    style: TextStyle(
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
                      controller: _titleController,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Color(0xFF111827),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Judul PR...',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Description',
                    style: TextStyle(
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
                      controller: _bodyController,
                      maxLines: 8,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Color(0xFF111827),
                        height: 1.5,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Jelasin PR-nya...',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => setState(() => _draft = !_draft),
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
                            _draft
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_rounded,
                            color: const Color(0xFF8B5CF6),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create as draft',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'PR yang belum siap di-review',
                                  style: TextStyle(
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
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBranchRow({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    // Pake for loop + var тЖТ gak ada masalah inferensi tipe sama sekali
    final List<DropdownMenuItem<String>> items = [];
    for (var i = 0; i < _branches.length; i++) {
      final branch = _branches[i];
      items.add(
        DropdownMenuItem<String>(
          value: branch.name,
          child: Text(
            branch.name,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Color(0xFF111827),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8B5CF6),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Color(0xFF111827),
                fontWeight: FontWeight.w600,
              ),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}