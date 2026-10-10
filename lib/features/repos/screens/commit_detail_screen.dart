import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/github_commit_detail.dart';
import '../../../data/services/auth_storage.dart';
import '../../../data/services/github_api_service.dart';

class CommitDetailScreen extends StatefulWidget {
  final String owner;
  final String repoName;
  final String sha;

  const CommitDetailScreen({
    super.key,
    required this.owner,
    required this.repoName,
    required this.sha,
  });

  @override
  State<CommitDetailScreen> createState() => _CommitDetailScreenState();
}

class _CommitDetailScreenState extends State<CommitDetailScreen> {
  GitHubCommitDetail? _commit;
  bool _isLoading = true;
  String? _error;
  String? _selectedFile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final token = await AuthStorage.getToken();
    if (token == null) {
      setState(() {
        _error = 'Token tidak ditemukan';
        _isLoading = false;
      });
      return;
    }

    final commit = await GitHubApiService.getCommitWithFiles(
      token,
      widget.owner,
      widget.repoName,
      widget.sha,
    );

    if (!mounted) return;
    setState(() {
      _commit = commit;
      _isLoading = false;
    });
  }

  Future<void> _openInBrowser() async {
    if (_commit?.htmlUrl == null) return;
    final uri = Uri.parse(_commit!.htmlUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
          icon: const Icon(Icons.arrow_back_rounded,
              color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _commit?.shortSha ?? 'Commit',
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded,
                color: Color(0xFF6366F1), size: 20),
            onPressed: _openInBrowser,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }

    if (_error != null || _commit == null) {
      return Center(
        child: Text(
          _error ?? 'Commit gak ketemu',
          style: const TextStyle(fontFamily: 'Inter'),
        ),
      );
    }

    final commit = _commit!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Commit message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commit.title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    height: 1.4,
                  ),
                ),
                if (commit.body.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    commit.body,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (commit.authorAvatar != null)
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(commit.authorAvatar!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      const Icon(Icons.person,
                          size: 20, color: Color(0xFF6B7280)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            commit.authorName ??
                                commit.authorLogin ??
                                'Unknown',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          Text(
                            commit.formattedDate,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stats
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    Icons.description_outlined,
                    '${commit.files.length}',
                    'Files',
                    const Color(0xFF6366F1),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.add_circle_outline_rounded,
                    '+${commit.additions}',
                    'Additions',
                    const Color(0xFF10B981),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.remove_circle_outline_rounded,
                    '-${commit.deletions}',
                    'Deletions',
                    const Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Files list
          Row(
            children: [
              const Text(
                'Changed Files',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${commit.files.length}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (commit.files.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Center(
                child: Text(
                  'Gak ada file yang berubah',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
            )
          else
            ...commit.files.map((f) => _buildFileCard(f)),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildFileCard(GitHubCommitFile file) {
    final isExpanded = _selectedFile == file.filename;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File header (tap buat expand)
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedFile = isExpanded ? null : file.filename;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    _statusIcon(file.status),
                    size: 16,
                    color: _statusColor(file.status),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.filename,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (file.previousFilename != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'dari: ${file.previousFilename}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // +/- stats
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '+${file.additions}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '-${file.deletions}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: const Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          ),

          // Patch (expanded)
          if (isExpanded) ...[
            const Divider(height: 1),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF0D1117),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildPatch(file.patch),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPatch(String? patch) {
    if (patch == null || patch.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Patch gak tersedia (file binary atau terlalu besar)',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: Color(0xFF8B949E),
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final lines = patch.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        Color bgColor = Colors.transparent;
        Color textColor = const Color(0xFFE6EDF3);

        if (line.startsWith('@@')) {
          // Hunk header
          bgColor = const Color(0xFF161B22);
          textColor = const Color(0xFF8B949E);
        } else if (line.startsWith('+')) {
          bgColor = const Color(0xFF033A16);
          textColor = const Color(0xFFA5D6A7);
        } else if (line.startsWith('-')) {
          bgColor = const Color(0xFF4C0F0F);
          textColor = const Color(0xFFEF9A9A);
        } else if (line.startsWith('diff') ||
            line.startsWith('index') ||
            line.startsWith('---') ||
            line.startsWith('+++')) {
          bgColor = const Color(0xFF161B22);
          textColor = const Color(0xFF8B949E);
        }

        return Container(
          width: double.infinity,
          color: bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          child: Text(
            line.isEmpty ? ' ' : line,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: textColor,
              height: 1.5,
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _statusIcon(String? status) {
    switch (status) {
      case 'added':
        return Icons.add_circle_outline_rounded;
      case 'removed':
        return Icons.remove_circle_outline_rounded;
      case 'renamed':
        return Icons.drive_file_rename_outline_rounded;
      case 'modified':
      default:
        return Icons.edit_outlined;
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'added':
        return const Color(0xFF10B981);
      case 'removed':
        return const Color(0xFFDC2626);
      case 'renamed':
        return const Color(0xFFF59E0B);
      case 'modified':
      default:
        return const Color(0xFF6366F1);
    }
  }
}