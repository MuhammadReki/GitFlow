import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/github_issue.dart';
import '../../../data/services/auth_storage.dart';
import '../../../data/services/github_api_service.dart';

class PRsScreen extends StatefulWidget {
  const PRsScreen({super.key});

  @override
  State<PRsScreen> createState() => _PRsScreenState();
}

class _PRsScreenState extends State<PRsScreen> {
  List<GitHubIssue> _allPRs = [];
  List<GitHubIssue> _filtered = [];
  bool _isLoading = true;
  String? _error;
  String _state = 'open'; // open, closed
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

    final prs = await GitHubApiService.getAllPullRequests(
      token,
      state: _state,
    );

    if (!mounted) return;
    setState(() {
      _allPRs = prs;
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    List<GitHubIssue> result = List.from(_allPRs);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((i) =>
              i.title.toLowerCase().contains(q) ||
              (i.body?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    setState(() {
      _filtered = result;
    });
  }

  Future<void> _openPR(GitHubIssue pr) async {
    if (pr.htmlUrl == null) return;
    final uri = Uri.parse(pr.htmlUrl!);
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
          'Pull Requests',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Color(0xFF6366F1)),
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStateChips(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) {
            _searchQuery = v;
            _applyFilter();
          },
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF111827),
          ),
          decoration: InputDecoration(
            hintText: 'Cari pull request...',
            hintStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF6B7280),
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStateChips() {
    final states = [
      {'key': 'open', 'label': 'Open'},
      {'key': 'closed', 'label': 'Closed'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: states.map((s) {
          final isActive = _state == s['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _state = s['key']!;
                });
                _load();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF6366F1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF6366F1)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Text(
                  s['label']!,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? Colors.white
                        : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(fontFamily: 'Inter'),
        ),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.merge_type_rounded,
                  size: 60, color: Color(0xFF9CA3AF)),
              const SizedBox(height: 16),
              Text(
                _state == 'open'
                    ? 'Gak ada PR terbuka'
                    : 'Gak ada PR tertutup',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: const Color(0xFF6366F1),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _buildPRCard(_filtered[i]),
      ),
    );
  }

  Widget _buildPRCard(GitHubIssue pr) {
    return GestureDetector(
      onTap: () => _openPR(pr),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  pr.isOpen
                      ? Icons.merge_type_rounded
                      : Icons.check_circle_rounded,
                  size: 16,
                  color: pr.isOpen
                      ? const Color(0xFF10B981)
                      : const Color(0xFF8B5CF6),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pr.title,
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
            if (pr.labels.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: pr.labels.take(3).map((label) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '#${pr.number}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '@${pr.userLogin ?? 'unknown'}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chat_bubble_outline_rounded,
                    size: 14, color: Color(0xFF6B7280)),
                const SizedBox(width: 4),
                Text(
                  '${pr.comments}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}