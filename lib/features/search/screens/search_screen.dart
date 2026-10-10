import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/github_repo.dart';
import '../../../data/models/github_user.dart';
import '../../../data/services/auth_storage.dart';
import '../../../data/services/github_api_service.dart';
import '../../repos/screens/repo_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _token;

  List<GitHubRepo> _repos = [];
  List<GitHubUser> _users = [];

  bool _isLoadingRepos = false;
  bool _isLoadingUsers = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _initToken();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initToken() async {
    _token = await AuthStorage.getToken();
  }

  Future<void> _doSearch() async {
    final q = _searchController.text.trim();
    if (q.isEmpty || _token == null) return;

    setState(() {
      _query = q;
      _hasSearched = true;
      _isLoadingRepos = true;
      _isLoadingUsers = true;
    });

    final reposFuture = GitHubApiService.searchRepos(_token!, q);
    final usersFuture = GitHubApiService.searchUsers(_token!, q);

    final repos = await reposFuture;
    if (!mounted) return;
    setState(() {
      _repos = repos;
      _isLoadingRepos = false;
    });

    final users = await usersFuture;
    if (!mounted) return;
    setState(() {
      _users = users;
      _isLoadingUsers = false;
    });
  }

  Future<void> _openRepo(GitHubRepo repo) async {
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
  }

  Future<void> _openUser(GitHubUser user) async {
    final uri = Uri.parse('https://github.com/${user.login}');
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
          'Search GitHub',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF6366F1),
              unselectedLabelColor: const Color(0xFF6B7280),
              indicatorColor: const Color(0xFF6366F1),
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Repositories'),
                Tab(text: 'Users'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReposTab(),
                _buildUsersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: TextField(
          controller: _searchController,
          onSubmitted: (_) => _doSearch(),
          textInputAction: TextInputAction.search,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF111827),
          ),
          decoration: InputDecoration(
            hintText: 'Cari repo atau user...',
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
            suffixIcon: IconButton(
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              color: const Color(0xFF6366F1),
              onPressed: _doSearch,
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

  Widget _buildReposTab() {
    if (!_hasSearched) return _buildEmpty('Cari repository GitHub');
    if (_isLoadingRepos) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }
    if (_repos.isEmpty) {
      return _buildEmpty('Gak ada repo dengan kata "$_query"');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: _repos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _buildRepoCard(_repos[i]),
    );
  }

  Widget _buildRepoCard(GitHubRepo repo) {
    return GestureDetector(
      onTap: () => _openRepo(repo),
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
            Text(
              repo.fullName,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6366F1),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (repo.description != null &&
                repo.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                repo.description!,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (repo.language != null) ...[
                  const Icon(Icons.circle,
                      size: 8, color: Color(0xFF6366F1)),
                  const SizedBox(width: 4),
                  Text(
                    repo.language!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                const Icon(Icons.star_rounded,
                    size: 14, color: Color(0xFFF59E0B)),
                const SizedBox(width: 3),
                Text(
                  '${repo.stargazersCount}',
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

  Widget _buildUsersTab() {
    if (!_hasSearched) return _buildEmpty('Cari user GitHub');
    if (_isLoadingUsers) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }
    if (_users.isEmpty) {
      return _buildEmpty('Gak ada user dengan kata "$_query"');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: _users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _buildUserCard(_users[i]),
    );
  }

  Widget _buildUserCard(GitHubUser user) {
    return GestureDetector(
      onTap: () => _openUser(user),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: user.avatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(user.avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: const Color(0xFFF3F4F6),
              ),
              child: user.avatarUrl == null
                  ? const Icon(Icons.person,
                      color: Color(0xFF6366F1), size: 24)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.login,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  if (user.name != null && user.name!.isNotEmpty)
                    Text(
                      user.name!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF9CA3AF), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_rounded,
                size: 60, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 16),
            Text(
              message,
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
}