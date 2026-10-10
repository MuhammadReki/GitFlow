import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/github_branch.dart';
import '../../../data/models/github_compare.dart';
import '../../../data/models/github_commit_detail.dart';
import '../../../data/services/auth_storage.dart';
import '../../../data/services/github_api_service.dart';
import 'commit_detail_screen.dart';

class CompareBranchesScreen extends StatefulWidget {
  final String owner;
  final String repoName;
  final String? defaultBase;
  final String? defaultHead;

  const CompareBranchesScreen({
    super.key,
    required this.owner,
    required this.repoName,
    this.defaultBase,
    this.defaultHead,
  });

  @override
  State<CompareBranchesScreen> createState() => _CompareBranchesScreenState();
}

class _CompareBranchesScreenState extends State<CompareBranchesScreen> {
  List<GitHubBranch> _branches = [];
  String? _baseBranch;
  String? _headBranch;
  GitHubCompare? _result;
  bool _isLoadingBranches = true;
  bool _isLoadingCompare = false;
  String? _error;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    setState(() {
      _isLoadingBranches = true;
      _error = null;
    });

    _token = await AuthStorage.getToken();
    if (_token == null) {
      setState(() {
        _error = 'Token tidak ditemukan';
        _isLoadingBranches = false;
      });
      return;
    }

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
        _baseBranch = widget.defaultBase ??
            (branches.length > 1 ? branches[1].name : branches[0].name);
        _headBranch = widget.defaultHead ?? branches[0].name;
      }
    });

    if (_baseBranch != null && _headBranch != null) {
      _loadComparison();
    }
  }

  Future<void> _loadComparison() async {
    if (_baseBranch == null || _headBranch == null || _token == null) {
      return;
    }

    if (_baseBranch == _headBranch) {
      setState(() {
        _result = null;
        _error = 'Base dan head branch gak boleh sama';
      });
      return;
    }

    setState(() {
      _isLoadingCompare = true;
      _error = null;
      _result = null;
    });

    final result = await GitHubApiService.compareBranches(
      _token!,
      widget.owner,
      widget.repoName,
      _baseBranch!,
      _headBranch!,
    );

    if (!mounted) return;
    setState(() {
      _result = result;
      _isLoadingCompare = false;
      if (result == null) {
        _error = 'Gagal compare branch. Cek branch-nya.';
      }
    });
  }

  Future<void> _openCommit(GitHubCompareCommit commit) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommitDetailScreen(
          owner: widget.owner,
          repoName: widget.repoName,
          sha: commit.sha,
        ),
      ),
    );
  }

  Future<void> _openInBrowser() async {
    if (_baseBranch == null || _headBranch == null) return;
    final url =
        'https://github.com/${widget.owner}/${widget.repoName}/compare/$_baseBranch...$_headBranch';
    final uri = Uri.parse(url);
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
        title: const Text(
          'Compare Branches',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
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
      body: _isLoadingBranches
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            )
          : Column(
              children: [
                _buildBranchSelector(),
                Expanded(child: _buildBody()),
              ],
            ),
    );
  }

  Widget _buildBranchSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildBranchDropdown(
              label: 'base',
              value: _baseBranch,
              onChanged: (v) {
                setState(() => _baseBranch = v);
                _loadComparison();
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.arrow_forward_rounded,
                size: 16, color: Color(0xFF6B7280)),
          ),
          Expanded(
            child: _buildBranchDropdown(
              label: 'head',
              value: _headBranch,
              onChanged: (v) {
                setState(() => _headBranch = v);
                _loadComparison();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchDropdown({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    final items = <DropdownMenuItem<String>>[];
    for (var i = 0; i < _branches.length; i++) {
      final b = _branches[i];
      items.add(
        DropdownMenuItem<String>(
          value: b.name,
          child: Text(
            b.name,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Color(0xFF111827),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6366F1),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
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

  Widget _buildBody() {
    if (_isLoadingCompare) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 60, color: Color(0xFFDC2626)),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadComparison,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_result == null) {
      return const Center(
        child: Text(
          'Pilih branch buat compare',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      );
    }

    final compare = _result!;

    return RefreshIndicator(
      onRefresh: _loadComparison,
      color: const Color(0xFF6366F1),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildStatusCard(compare),
          const SizedBox(height: 20),
          if (compare.commits.isNotEmpty) ...[
            Row(
              children: [
                const Text(
                  'Commits',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(width: 8),
                _buildCountBadge('${compare.commits.length}'),
              ],
            ),
            const SizedBox(height: 12),
            ...compare.commits.map((c) => _buildCommitCard(c)),
            const SizedBox(height: 20),
          ],
          if (compare.files.isNotEmpty) ...[
            Row(
              children: [
                const Text(
                  'Files Changed',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(width: 8),
                _buildCountBadge('${compare.files.length}'),
              ],
            ),
            const SizedBox(height: 12),
            ...compare.files.map((f) => _buildFileCard(f)),
          ],
          if (compare.commits.isEmpty && compare.files.isEmpty)
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
                  'Gak ada perbedaan',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(GitHubCompare compare) {
    final color = compare.isIdentical
        ? const Color(0xFF6B7280)
        : compare.isAhead
            ? const Color(0xFF10B981)
            : compare.isBehind
                ? const Color(0xFFDC2626)
                : const Color(0xFFF59E0B);

    final icon = compare.isIdentical
        ? Icons.check_circle_outline_rounded
        : compare.isAhead
            ? Icons.arrow_upward_rounded
            : compare.isBehind
                ? Icons.arrow_downward_rounded
                : Icons.compare_arrows_rounded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  compare.statusLabel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${compare.files.length} file${compare.files.length != 1 ? 's' : ''} changed тАв ${compare.totalCommits} commit${compare.totalCommits != 1 ? 's' : ''}',
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
    );
  }

  Widget _buildCountBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildCommitCard(GitHubCompareCommit commit) {
    return GestureDetector(
      onTap: () => _openCommit(commit),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.commit_rounded,
                    size: 14, color: Color(0xFF6366F1)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    commit.title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    commit.shortSha,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (commit.authorLogin != null) ...[
                  Text(
                    '@${commit.authorLogin}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    commit.formattedDate,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 16, color: Color(0xFF9CA3AF)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileCard(GitHubCommitFile file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _statusIcon(file.status),
                size: 14,
                color: _statusColor(file.status),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
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
              ),
            ],
          ),
          if (file.patch != null && file.patch!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildPatchLines(file.patch!),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
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
              const SizedBox(width: 10),
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
        ],
      ),
    );
  }

  List<Widget> _buildPatchLines(String patch) {
    final lines = patch.split('\n');
    final maxLines = lines.length > 30 ? 30 : lines.length;
    final displayLines = lines.sublist(0, maxLines);

    final widgets = displayLines.map<Widget>((String line) {
      Color bgColor = Colors.transparent;
      Color textColor = const Color(0xFFE6EDF3);

      if (line.startsWith('@@')) {
        bgColor = const Color(0xFF161B22);
        textColor = const Color(0xFF8B949E);
      } else if (line.startsWith('+')) {
        bgColor = const Color(0xFF033A16);
        textColor = const Color(0xFFA5D6A7);
      } else if (line.startsWith('-')) {
        bgColor = const Color(0xFF4C0F0F);
        textColor = const Color(0xFFEF9A9A);
      }

      return Container(
        width: double.infinity,
        color: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        child: Text(
          line.isEmpty ? ' ' : line,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            color: textColor,
            height: 1.4,
          ),
        ),
      );
    }).toList();

    if (lines.length > maxLines) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '... ${lines.length - maxLines} more lines',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              color: Color(0xFF8B949E),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return widgets;
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