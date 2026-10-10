import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/github_user.dart';
import '../../../data/models/github_repo.dart';
import '../../../data/services/auth_storage.dart';
import '../../../data/services/github_api_service.dart';
import '../../repos/screens/repo_detail_screen.dart';

class UserProfileExternalScreen extends StatefulWidget {
  final String username;

  const UserProfileExternalScreen({
    super.key,
    required this.username,
  });

  @override
  State<UserProfileExternalScreen> createState() =>
      _UserProfileExternalScreenState();
}

class _UserProfileExternalScreenState
    extends State<UserProfileExternalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  GitHubUser? _user;
  List<GitHubRepo> _repos = [];
  bool _isLoading = true;
  String? _error;
  String? _token;

  bool _isFollowing = false;
  bool _isFollowLoading = false;
  bool _isOwnProfile = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
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

    // Cek apakah ini profile sendiri
    final me = await GitHubApiService.getUser(_token!);
    _isOwnProfile = me?.login == widget.username;

    final user = await GitHubApiService.getUserByUsername(
      _token!,
      widget.username,
    );
    final repos = await GitHubApiService.getUserReposByUsername(
      _token!,
      widget.username,
    );

    bool isFollowing = false;
    if (!_isOwnProfile) {
      isFollowing = await GitHubApiService.checkFollowing(
        _token!,
        widget.username,
      );
    }

    if (!mounted) return;
    setState(() {
      _user = user;
      _repos = repos;
      _isFollowing = isFollowing;
      _isLoading = false;
    });
  }

  Future<void> _toggleFollow() async {
    if (_token == null || _isOwnProfile) return;
    setState(() => _isFollowLoading = true);

    bool ok;
    if (_isFollowing) {
      ok = await GitHubApiService.unfollowUser(_token!, widget.username);
    } else {
      ok = await GitHubApiService.followUser(_token!, widget.username);
    }

    if (!mounted) return;

    if (ok) {
      setState(() {
        _isFollowing = !_isFollowing;
        _isFollowLoading = false;
        // Update follower count locally
        if (_user != null) {
          final newCount = _isFollowing
              ? _user!.followers + 1
              : _user!.followers - 1;
          _user = GitHubUser(
            login: _user!.login,
            name: _user!.name,
            avatarUrl: _user!.avatarUrl,
            bio: _user!.bio,
            company: _user!.company,
            location: _user!.location,
            blog: _user!.blog,
            twitterUsername: _user!.twitterUsername,
            email: _user!.email,
            hireable: _user!.hireable,
            publicRepos: _user!.publicRepos,
            publicGists: _user!.publicGists,
            followers: newCount < 0 ? 0 : newCount,
            following: _user!.following,
            createdAt: _user!.createdAt,
            updatedAt: _user!.updatedAt,
            htmlUrl: _user!.htmlUrl,
          );
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isFollowing ? 'Followed @${widget.username}' : 'Unfollowed @${widget.username}'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } else {
      setState(() => _isFollowLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal follow/unfollow'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
    }
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    String fullUrl = url;
    if (!url.startsWith('http')) fullUrl = 'https://$url';
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
      return const Scaffold(
        backgroundColor: Color(0xFFF9FAFB),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
      );
    }

    if (_error != null || _user == null) {
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
        ),
        body: Center(
          child: Text(
            _error ?? 'User gak ketemu',
            style: const TextStyle(fontFamily: 'Inter'),
          ),
        ),
      );
    }

    final user = _user!;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Color(0xFF111827)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              '@${user.login}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
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
                    Tab(text: 'Profile'),
                    Tab(text: 'Repositories'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProfileTab(user),
            _buildReposTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(GitHubUser user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
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
              fontSize: 22,
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
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),

          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                user.bio!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Color(0xFF374151),
                  height: 1.5,
                ),
              ),
            ),
          ],

          // Follow button
          if (!_isOwnProfile) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: GestureDetector(
                onTap: _isFollowLoading ? null : _toggleFollow,
                child: Container(
                  decoration: BoxDecoration(
                    color: _isFollowing
                        ? Colors.white
                        : const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isFollowing
                          ? const Color(0xFFE5E7EB)
                          : const Color(0xFF6366F1),
                      width: 1.5,
                    ),
                  ),
                  child: _isFollowLoading
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isFollowing
                                  ? Icons.person_remove_rounded
                                  : Icons.person_add_rounded,
                              color: _isFollowing
                                  ? const Color(0xFF6B7280)
                                  : Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isFollowing ? 'Unfollow' : 'Follow',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _isFollowing
                                    ? const Color(0xFF6B7280)
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Stats
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
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
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

  Widget _buildReposTab() {
    if (_repos.isEmpty) {
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

    return RefreshIndicator(
      onRefresh: _load,
      color: const Color(0xFF6366F1),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _repos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _buildRepoCard(_repos[i]),
      ),
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