import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/github_repo.dart';
import '../../../data/models/github_file.dart';
import '../../../data/models/github_issue.dart';
import '../../../data/models/github_commit.dart';
import '../../../data/models/github_pr.dart';
import '../../../data/services/auth_storage.dart';
import '../../../data/services/github_api_service.dart';
import '../../issues/screens/create_issue_screen.dart';
import '../../issues/screens/issue_detail_screen.dart';
import '../../prs/screens/create_pr_screen.dart';
import '../../prs/screens/pr_detail_screen.dart';

class RepoDetailScreen extends StatefulWidget {
  final String owner;
  final String repoName;

  const RepoDetailScreen({
    super.key,
    required this.owner,
    required this.repoName,
  });

  @override
  State<RepoDetailScreen> createState() => _RepoDetailScreenState();
}

class _RepoDetailScreenState extends State<RepoDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  GitHubRepo? _repo;
  List<GitHubFile> _files = [];
  String? _readme;
  List<GitHubIssue> _issues = [];
  List<GitHubCommit> _commits = [];
  List<GitHubPR> _prs = [];
  bool _isLoading = true;
  String? _error;
  String _currentPath = '';

  bool _isStarred = false;
  bool _isStarLoading = false;

  bool _isForking = false;
  String? _myForkFullName;

  String? _token;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
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

    final repo = await GitHubApiService.getRepo(
      _token!,
      widget.owner,
      widget.repoName,
    );
    final files = await GitHubApiService.getRepoContents(
      _token!,
      widget.owner,
      widget.repoName,
    );
    final readme = await GitHubApiService.getReadme(
      _token!,
      widget.owner,
      widget.repoName,
    );
    final issues = await GitHubApiService.getIssues(
      _token!,
      widget.owner,
      widget.repoName,
    );
    final commits = await GitHubApiService.getCommits(
      _token!,
      widget.owner,
      widget.repoName,
    );
    final prs = await GitHubApiService.getPRs(
      _token!,
      widget.owner,
      widget.repoName,
    );
    final isStarred = await GitHubApiService.isRepoStarred(
      _token!,
      widget.owner,
      widget.repoName,
    );
    final myFork = await GitHubApiService.getMyFork(
      _token!,
      widget.owner,
      widget.repoName,
    );

    if (!mounted) return;
    setState(() {
      _repo = repo;
      _files = files;
      _readme = readme;
      _issues = issues;
      _commits = commits;
      _prs = prs;
      _isStarred = isStarred;
      _myForkFullName = myFork;
      _isLoading = false;
    });
  }

  Future<void> _toggleStar() async {
    if (_token == null) return;
    setState(() => _isStarLoading = true);

    bool ok;
    if (_isStarred) {
      ok = await GitHubApiService.unstarRepo(
        _token!,
        widget.owner,
        widget.repoName,
      );
    } else {
      ok = await GitHubApiService.starRepo(
        _token!,
        widget.owner,
        widget.repoName,
      );
    }

    if (!mounted) return;
    if (ok) {
      setState(() {
        _isStarred = !_isStarred;
        _isStarLoading = false;
        if (_repo != null) {
          final newCount = _isStarred
              ? _repo!.stargazersCount + 1
              : _repo!.stargazersCount - 1;
          _repo = GitHubRepo(
            id: _repo!.id,
            name: _repo!.name,
            fullName: _repo!.fullName,
            description: _repo!.description,
            language: _repo!.language,
            stargazersCount: newCount < 0 ? 0 : newCount,
            forksCount: _repo!.forksCount,
            watchersCount: _repo!.watchersCount,
            openIssuesCount: _repo!.openIssuesCount,
            isPrivate: _repo!.isPrivate,
            isFork: _repo!.isFork,
            htmlUrl: _repo!.htmlUrl,
            defaultBranch: _repo!.defaultBranch,
            updatedAt: _repo!.updatedAt,
          );
        }
      });
    } else {
      setState(() => _isStarLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isStarred ? 'Gagal unstar repo' : 'Gagal star repo'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  Future<void> _forkRepo() async {
    if (_token == null) return;

    if (_myForkFullName != null) {
      final parts = _myForkFullName!.split('/');
      if (parts.length == 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RepoDetailScreen(
              owner: parts[0],
              repoName: parts[1],
            ),
          ),
        );
      }
      return;
    }

    setState(() => _isForking = true);

    final result = await GitHubApiService.forkRepo(
      _token!,
      widget.owner,
      widget.repoName,
    );

    if (!mounted) return;

    if (result != null) {
      final forkFullName = result['full_name'] as String?;
      setState(() {
        _myForkFullName = forkFullName;
        _isForking = false;
        if (_repo != null) {
          _repo = GitHubRepo(
            id: _repo!.id,
            name: _repo!.name,
            fullName: _repo!.fullName,
            description: _repo!.description,
            language: _repo!.language,
            stargazersCount: _repo!.stargazersCount,
            forksCount: _repo!.forksCount + 1,
            watchersCount: _repo!.watchersCount,
            openIssuesCount: _repo!.openIssuesCount,
            isPrivate: _repo!.isPrivate,
            isFork: _repo!.isFork,
            htmlUrl: _repo!.htmlUrl,
            defaultBranch: _repo!.defaultBranch,
            updatedAt: _repo!.updatedAt,
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Repo berhasil di-fork ke $forkFullName'),
          backgroundColor: const Color(0xFF10B981),
          action: SnackBarAction(
            label: 'BUKA',
            textColor: Colors.white,
            onPressed: () {
              if (forkFullName != null) {
                final parts = forkFullName.split('/');
                if (parts.length == 2) {
                  Navigator.pushReplacement(
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
            },
          ),
        ),
      );
    } else {
      setState(() => _isForking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal fork repo. Coba lagi nanti.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
    }
  }

  Future<void> _loadFilesAtPath(String path) async {
    if (_token == null) return;
    final files = await GitHubApiService.getRepoContents(
      _token!,
      widget.owner,
      widget.repoName,
      path: path,
    );
    if (!mounted) return;
    setState(() {
      _files = files;
      _currentPath = path;
    });
  }

  Future<void> _openInBrowser() async {
    if (_repo?.htmlUrl == null) return;
    final uri = Uri.parse(_repo!.htmlUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openCommitInBrowser(GitHubCommit commit) async {
    if (commit.htmlUrl == null) return;
    final uri = Uri.parse(commit.htmlUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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

    if (_error != null || _repo == null) {
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
            _error ?? 'Repo gak ketemu',
            style: const TextStyle(fontFamily: 'Inter'),
          ),
        ),
      );
    }

    final repo = _repo!;

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
            actions: [
              IconButton(
                icon: const Icon(Icons.open_in_new_rounded,
                    color: Color(0xFF6366F1), size: 20),
                onPressed: _openInBrowser,
              ),
            ],
            title: Text(
              repo.name,
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
                  isScrollable: true,
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
                    Tab(text: 'Overview'),
                    Tab(text: 'Files'),
                    Tab(text: 'Commits'),
                    Tab(text: 'PRs'),
                    Tab(text: 'Issues'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(repo),
            _buildFilesTab(),
            _buildCommitsTab(),
            _buildPRsTab(),
            _buildIssuesTab(),
          ],
        ),
      ),
    );
  }

  // ═══ OVERVIEW ═══
  Widget _buildOverviewTab(GitHubRepo repo) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildStarButton()),
              const SizedBox(width: 10),
              Expanded(child: _buildForkButton()),
            ],
          ),
          const SizedBox(height: 16),
          if (repo.description != null && repo.description!.isNotEmpty) ...[
            Text(
              repo.description!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF111827),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                _buildStatItem(Icons.star_rounded,
                    '${repo.stargazersCount}', 'Stars', const Color(0xFFF59E0B)),
                _buildStatItem(Icons.fork_right_rounded,
                    '${repo.forksCount}', 'Forks', const Color(0xFF6366F1)),
                _buildStatItem(Icons.visibility_rounded,
                    '${repo.watchersCount}', 'Watch', const Color(0xFF10B981)),
                _buildStatItem(Icons.error_outline_rounded,
                    '${repo.openIssuesCount}', 'Issues', const Color(0xFFDC2626)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Owner', repo.fullName.split('/')[0]),
          _buildInfoRow('Language', repo.language ?? '-'),
          _buildInfoRow('Branch', repo.defaultBranch ?? 'main'),
          _buildInfoRow(
              'Visibility', repo.isPrivate ? 'Private' : 'Public'),
          const SizedBox(height: 24),
          if (_readme != null && _readme!.isNotEmpty) ...[
            const Text(
              'README',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                _readme!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Color(0xFF374151),
                  height: 1.6,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStarButton() {
    return GestureDetector(
      onTap: _isStarLoading ? null : _toggleStar,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _isStarred
              ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isStarred
                ? const Color(0xFFF59E0B)
                : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isStarLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFF59E0B),
                ),
              )
            else
              Icon(
                _isStarred
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: _isStarred
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF6B7280),
                size: 20,
              ),
            const SizedBox(width: 8),
            Text(
              _isStarred ? 'Starred' : 'Star',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _isStarred
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForkButton() {
    final hasForked = _myForkFullName != null;
    return GestureDetector(
      onTap: _isForking ? null : _forkRepo,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: hasForked
              ? const Color(0xFF6366F1).withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasForked
                ? const Color(0xFF6366F1)
                : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isForking)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF6366F1),
                ),
              )
            else
              Icon(
                Icons.fork_right_rounded,
                color: hasForked
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF6B7280),
                size: 20,
              ),
            const SizedBox(width: 8),
            Text(
              hasForked ? 'View Fork' : 'Fork',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: hasForked
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══ FILES ═══
  Widget _buildFilesTab() {
    return Column(
      children: [
        if (_currentPath.isNotEmpty)
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _loadFilesAtPath(''),
                  child: const Icon(Icons.home_rounded,
                      size: 18, color: Color(0xFF6366F1)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '/$_currentPath',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: _files.isEmpty
              ? const Center(
                  child: Text(
                    'Folder kosong',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _files.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    return _buildFileItem(_files[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFileItem(GitHubFile file) {
    return GestureDetector(
      onTap: () {
        if (file.isDirectory) {
          _loadFilesAtPath(file.path);
        } else {
          _openInBrowser();
        }
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(
              file.isDirectory
                  ? Icons.folder_rounded
                  : Icons.insert_drive_file_rounded,
              color: file.isDirectory
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF6B7280),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                file.name,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Color(0xFF111827),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (file.size != null && file.isFile)
              Text(
                _formatBytes(file.size!),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024)
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ═══ COMMITS ═══
  Widget _buildCommitsTab() {
    if (_commits.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.commit_rounded,
                size: 60, color: Color(0xFF9CA3AF)),
            SizedBox(height: 12),
            Text(
              'Belum ada commit',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAll,
      color: const Color(0xFF6366F1),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _commits.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return _buildCommitCard(_commits[index]);
        },
      ),
    );
  }

  Widget _buildCommitCard(GitHubCommit commit) {
    return GestureDetector(
      onTap: () => _openCommitInBrowser(commit),
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
                const Icon(Icons.commit_rounded,
                    size: 16, color: Color(0xFF6366F1)),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
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
                Expanded(
                  child: Text(
                    commit.formattedDate,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (commit.authorAvatar != null)
                  Container(
                    width: 20,
                    height: 20,
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
                      size: 16, color: Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    commit.authorLogin ??
                        commit.authorName ??
                        'Unknown',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.open_in_new_rounded,
                    size: 14, color: Color(0xFF9CA3AF)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══ PRs ═══
  Widget _buildPRsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreatePRScreen(
                    owner: widget.owner,
                    repoName: widget.repoName,
                  ),
                ),
              );
              if (result == true) _loadAll();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'New Pull Request',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: _prs.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.merge_type_rounded,
                          size: 60, color: Color(0xFF9CA3AF)),
                      SizedBox(height: 12),
                      Text(
                        'Gak ada PR terbuka',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _prs.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final pr = _prs[index];
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PRDetailScreen(
                              owner: widget.owner,
                              repoName: widget.repoName,
                              prNumber: pr.number,
                            ),
                          ),
                        );
                        _loadAll();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  pr.isMerged
                                      ? Icons.check_circle_rounded
                                      : pr.isOpen
                                          ? Icons.merge_type_rounded
                                          : Icons.cancel_rounded,
                                  size: 16,
                                  color: pr.isMerged
                                      ? const Color(0xFF8B5CF6)
                                      : pr.isOpen
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFDC2626),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '#${pr.number} ${pr.title}',
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
                                Text(
                                  '@${pr.userLogin ?? 'unknown'}',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'тАв ${pr.formattedDate}',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 14,
                                    color: Color(0xFF6B7280)),
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
                  },
                ),
        ),
      ],
    );
  }

  // ═══ ISSUES ═══
  Widget _buildIssuesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateIssueScreen(
                    owner: widget.owner,
                    repoName: widget.repoName,
                  ),
                ),
              );
              if (result == true) _loadAll();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'New Issue',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: _issues.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          size: 60, color: Color(0xFF10B981)),
                      SizedBox(height: 12),
                      Text(
                        'Gak ada issue terbuka',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _issues.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final issue = _issues[index];
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IssueDetailScreen(
                              owner: widget.owner,
                              repoName: widget.repoName,
                              issueNumber: issue.number,
                            ),
                          ),
                        );
                        _loadAll();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  issue.isOpen
                                      ? Icons.error_outline_rounded
                                      : Icons.check_circle_outline_rounded,
                                  size: 16,
                                  color: issue.isOpen
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFDC2626),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '#${issue.number} ${issue.title}',
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
                            if (issue.labels.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                children: issue.labels.take(3).map((label) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6366F1)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      label,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6366F1),
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
                                  '@${issue.userLogin ?? 'unknown'}',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 14,
                                    color: Color(0xFF6B7280)),
                                const SizedBox(width: 4),
                                Text(
                                  '${issue.comments}',
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
                  },
                ),
        ),
      ],
    );
  }
}