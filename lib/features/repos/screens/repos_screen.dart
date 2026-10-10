import 'package:flutter/material.dart';

import '../../../data/models/github_repo.dart';
import '../../../data/services/auth_storage.dart';
import '../../../data/services/github_api_service.dart';
import 'repo_detail_screen.dart';

class ReposScreen extends StatefulWidget {
  const ReposScreen({super.key});

  @override
  State<ReposScreen> createState() => _ReposScreenState();
}

class _ReposScreenState extends State<ReposScreen> {
  List<GitHubRepo> _allRepos = [];
  List<GitHubRepo> _filteredRepos = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _filterType = 'all'; // all, public, private, forked

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRepos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRepos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final token = await AuthStorage.getToken();
    if (token == null) {
      setState(() {
        _error = 'Token tidak ditemukan. Silakan login ulang.';
        _isLoading = false;
      });
      return;
    }

    final repos = await GitHubApiService.getUserRepos(token, perPage: 100);

    if (!mounted) return;
    setState(() {
      _allRepos = repos;
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    List<GitHubRepo> result = List.from(_allRepos);

    // Filter by type
    switch (_filterType) {
      case 'public':
        result = result.where((r) => !r.isPrivate).toList();
        break;
      case 'private':
        result = result.where((r) => r.isPrivate).toList();
        break;
      case 'forked':
        result = result.where((r) => r.isFork).toList();
        break;
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((r) =>
              r.name.toLowerCase().contains(q) ||
              (r.description?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    setState(() {
      _filteredRepos = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Repositories',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Semua repo GitHub lu',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadRepos,
            icon: const Icon(Icons.refresh_rounded),
            color: const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            _searchQuery = value;
            _applyFilter();
          },
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF111827),
          ),
          decoration: InputDecoration(
            hintText: 'Cari repository...',
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
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _searchQuery = '';
                      _applyFilter();
                    },
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: const Color(0xFF6B7280),
                  )
                : null,
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

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'All'},
      {'key': 'public', 'label': 'Public'},
      {'key': 'private', 'label': 'Private'},
      {'key': 'forked', 'label': 'Forked'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isActive = _filterType == f['key'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _filterType = f['key']!;
                  });
                  _applyFilter();
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
                    f['label']!,
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 60,
                color: Color(0xFFDC2626),
              ),
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
                onPressed: _loadRepos,
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

    if (_filteredRepos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.folder_off_rounded,
                size: 60,
                color: Color(0xFF9CA3AF),
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty
                    ? 'Repository "$_searchQuery" gak ketemu'
                    : 'Belum ada repository',
                textAlign: TextAlign.center,
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
      onRefresh: _loadRepos,
      color: const Color(0xFF6366F1),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        itemCount: _filteredRepos.length,
        itemBuilder: (context, index) {
          return _buildRepoCard(_filteredRepos[index]);
        },
      ),
    );
  }

  Widget _buildRepoCard(GitHubRepo repo) {
    return GestureDetector(
      onTap: () {
        final parts = repo.fullName.split('/');
        if (parts.length == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RepoDetailScreen(
                owner: parts[0],
                repoName: parts[1],
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  repo.isPrivate
                      ? Icons.lock_rounded
                      : Icons.public_rounded,
                  size: 16,
                  color: const Color(0xFF6B7280),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    repo.name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6366F1),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (repo.isFork)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Fork',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
              ],
            ),
            if (repo.description != null &&
                repo.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                repo.description!,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (repo.language != null) ...[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _languageColor(repo.language!),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    repo.language!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: Color(0xFFF59E0B),
                ),
                const SizedBox(width: 4),
                Text(
                  '${repo.stargazersCount}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.fork_right_rounded,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 4),
                Text(
                  '${repo.forksCount}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _languageColor(String language) {
    const colors = {
      'Dart': Color(0xFF00B4AB),
      'JavaScript': Color(0xFFF1E05A),
      'TypeScript': Color(0xFF3178C6),
      'Python': Color(0xFF3572A5),
      'Java': Color(0xFFB07219),
      'Kotlin': Color(0xFFA97BFF),
      'Swift': Color(0xFFF05138),
      'Go': Color(0xFF00ADD8),
      'Rust': Color(0xFFDEA584),
      'C++': Color(0xFFF34B7D),
      'C': Color(0xFF555555),
      'C#': Color(0xFF178600),
      'Ruby': Color(0xFF701516),
      'PHP': Color(0xFF4F5D95),
      'HTML': Color(0xFFE34C26),
      'CSS': Color(0xFF563D7C),
      'Shell': Color(0xFF89E051),
    };
    return colors[language] ?? const Color(0xFF6366F1);
  }
}