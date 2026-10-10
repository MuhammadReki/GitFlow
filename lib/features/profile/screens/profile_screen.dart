import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/github_user.dart';
import '../../../data/models/github_repo.dart';
import '../../../data/services/auth_storage.dart';
import '../../../data/services/github_api_service.dart';
import '../../repos/screens/repo_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  GitHubUser? _user;
  List<GitHubRepo> _repos = [];
  bool _isLoading = true;
  String? _error;
  String? _token;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    _token = await AuthStorage.getToken();
    if (_token == null) {
      setState(() {
        _error = 'Token tidak ditemukan';
        _isLoading = false;
      });
      return;
    }

    final user = await GitHubApiService.getUser(_token!);
    final repos = await GitHubApiService.getUserRepos(_token!);

    if (!mounted) return;
    setState(() {
      _user = user;
      _repos = repos;
      _isLoading = false;
    });
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    String fullUrl = url;
    if (!url.startsWith('http')) {
      fullUrl = 'https://$url';
    }
    final uri = Uri.parse(fullUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }

    if (_error != null || _user == null) {
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
                _error ?? 'Gagal load profile',
                style: const TextStyle(fontFamily: 'Inter'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfile,
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

    final user = _user!;

    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: const Color(0xFF6366F1),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(user),
            _buildInfoSection(user),
            _buildTabBar(),
            _buildTabContent(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ═══ HEADER (avatar + nama + bio) ═══
  Widget _buildHeader(GitHubUser user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF6366F1), width: 3),
              image: user.avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(user.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: user.avatarUrl == null
                ? const Icon(Icons.person,
                    color: Color(0xFF6366F1), size: 55)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.name ?? user.login,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '@${user.login}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: Color(0xFF6B7280),
            ),
          ),
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                user.bio!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF374151),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══ INFO SECTION (stats + details) ═══
  Widget _buildInfoSection(GitHubUser user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Stats card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildStatBox('${user.publicRepos}', 'Repos'),
                _buildStatBox('${user.followers}', 'Followers'),
                _buildStatBox('${user.following}', 'Following'),
                _buildStatBox('${user.publicGists}', 'Gists'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Detail rows
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                if (user.company != null && user.company!.isNotEmpty)
                  _buildDetailRow(
                    Icons.business_rounded,
                    user.company!.replaceAll('@', ''),
                  ),
                if (user.location != null && user.location!.isNotEmpty)
                  _buildDetailRow(
                    Icons.location_on_rounded,
                    user.location!,
                  ),
                if (user.email != null && user.email!.isNotEmpty)
                  _buildDetailRow(
                    Icons.email_rounded,
                    user.email!,
                  ),
                if (user.blog != null && user.blog!.isNotEmpty)
                  _buildDetailRow(
                    Icons.link_rounded,
                    user.blog!,
                    onTap: () => _openUrl(user.blog!),
                    isLink: true,
                  ),
                if (user.twitterUsername != null &&
                    user.twitterUsername!.isNotEmpty)
                  _buildDetailRow(
                    Icons.alternate_email_rounded,
                    '@${user.twitterUsername}',
                    onTap: () => _openUrl(
                        'https://twitter.com/${user.twitterUsername}'),
                    isLink: true,
                  ),
                _buildDetailRow(
                  Icons.calendar_today_rounded,
                  user.joinedDate,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatBox(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String text, {
    VoidCallback? onTap,
    bool isLink = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF6B7280)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: isLink
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF374151),
                  fontWeight:
                      isLink ? FontWeight.w600 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isLink)
              const Icon(Icons.open_in_new_rounded,
                  size: 14, color: Color(0xFF6366F1)),
          ],
        ),
      ),
    );
  }

  // ═══ TAB BAR ═══
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
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
          Tab(text: 'Starred'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 400,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildReposList(_repos, false),
          _buildReposList([], true), // Placeholder starred
        ],
      ),
    );
  }

  Widget _buildReposList(List<GitHubRepo> repos, bool isStarred) {
    if (isStarred) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_border_rounded,
                  size: 60, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'Starred repos coming soon',
                style: TextStyle(
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

    if (repos.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada repo',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: repos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _buildRepoCard(repos[i]),
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
            Row(
              children: [
                Icon(
                  repo.isPrivate
                      ? Icons.lock_rounded
                      : Icons.public_rounded,
                  size: 14,
                  color: const Color(0xFF6B7280),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    repo.name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6366F1),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (repo.isFork)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Fork',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
              ],
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
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6366F1),
                      shape: BoxShape.circle,
                    ),
                  ),
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
                const SizedBox(width: 12),
                const Icon(Icons.fork_right_rounded,
                    size: 14, color: Color(0xFF6B7280)),
                const SizedBox(width: 3),
                Text(
                  '${repo.forksCount}',
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