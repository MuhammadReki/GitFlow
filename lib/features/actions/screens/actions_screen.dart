import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/github_action.dart';
import '../../../data/services/auth_storage.dart';
import '../../../data/services/github_api_service.dart';
import 'run_detail_screen.dart';

class ActionsScreen extends StatefulWidget {
  final String owner;
  final String repoName;

  const ActionsScreen({
    super.key,
    required this.owner,
    required this.repoName,
  });

  @override
  State<ActionsScreen> createState() => _ActionsScreenState();
}

class _ActionsScreenState extends State<ActionsScreen> {
  List<GitHubWorkflowRun> _runs = [];
  bool _isLoading = true;
  String? _error;
  String _filterStatus = 'all';

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

    final runs = await GitHubApiService.getWorkflowRuns(
      token,
      widget.owner,
      widget.repoName,
    );

    if (!mounted) return;
    setState(() {
      _runs = runs;
      _isLoading = false;
    });
  }

  List<GitHubWorkflowRun> get _filteredRuns {
    switch (_filterStatus) {
      case 'success':
        return _runs.where((r) => r.isSuccess).toList();
      case 'failure':
        return _runs.where((r) => r.isFailure).toList();
      case 'in_progress':
        return _runs.where((r) => r.isInProgress).toList();
      default:
        return _runs;
    }
  }

  Future<void> _openRun(GitHubWorkflowRun run) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RunDetailScreen(
          owner: widget.owner,
          repoName: widget.repoName,
          run: run,
        ),
      ),
    );
  }

  Future<void> _openInBrowser(GitHubWorkflowRun run) async {
    if (run.htmlUrl == null) return;
    final uri = Uri.parse(run.htmlUrl!);
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
          'Actions',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Color(0xFF6366F1), size: 22),
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final List<Map<String, dynamic>> filters = [
      {'key': 'all', 'label': 'All', 'color': const Color(0xFF6366F1)},
      {
        'key': 'in_progress',
        'label': 'Running',
        'color': const Color(0xFFF59E0B)
      },
      {'key': 'success', 'label': 'Success', 'color': const Color(0xFF10B981)},
      {'key': 'failure', 'label': 'Failed', 'color': const Color(0xFFDC2626)},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map<Widget>((Map<String, dynamic> f) {
            final bool isActive = _filterStatus == f['key'];
            final Color color = f['color'] as Color;
            final String key = f['key'] as String;
            final String label = f['label'] as String;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _filterStatus = key),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? color : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? color : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          isActive ? Colors.white : const Color(0xFF6B7280),
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
                onPressed: _load,
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

    if (_filteredRuns.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_circle_outline_rounded,
                  size: 60, color: Color(0xFF9CA3AF)),
              const SizedBox(height: 16),
              Text(
                _filterStatus == 'all'
                    ? 'Belum ada workflow run'
                    : 'Gak ada run dengan filter ini',
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
        itemCount: _filteredRuns.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _buildRunCard(_filteredRuns[i]),
      ),
    );
  }

  Widget _buildRunCard(GitHubWorkflowRun run) {
    return GestureDetector(
      onTap: () => _openRun(run),
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
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _statusColor(run).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _statusIcon(run),
                    size: 16,
                    color: _statusColor(run),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        run.name ?? 'Workflow',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '#${run.runNumber ?? '-'}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'тАв ${run.statusLabel}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _statusColor(run),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _openInBrowser(run),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.open_in_new_rounded,
                      size: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (run.headBranch != null) ...[
                  const Icon(Icons.account_tree_outlined,
                      size: 12, color: Color(0xFF6B7280)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      run.headBranch!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (run.event != null) ...[
                  const Icon(Icons.bolt_rounded,
                      size: 12, color: Color(0xFF6B7280)),
                  const SizedBox(width: 2),
                  Text(
                    run.event!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  run.duration,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (run.actorAvatar != null)
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(run.actorAvatar!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  const Icon(Icons.person,
                      size: 12, color: Color(0xFF6B7280)),
                const SizedBox(width: 4),
                Text(
                  run.actorLogin ?? 'unknown',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    run.shortSha,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  run.formattedDate,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(GitHubWorkflowRun run) {
    if (run.isInProgress) {
      return run.status == 'queued'
          ? Icons.schedule_rounded
          : Icons.sync_rounded;
    }
    if (run.isSuccess) return Icons.check_circle_rounded;
    if (run.isFailure) return Icons.cancel_rounded;
    if (run.isCancelled) return Icons.block_rounded;
    if (run.isSkipped) return Icons.skip_next_rounded;
    return Icons.help_outline_rounded;
  }

  Color _statusColor(GitHubWorkflowRun run) {
    if (run.isInProgress) return const Color(0xFFF59E0B);
    if (run.isSuccess) return const Color(0xFF10B981);
    if (run.isFailure) return const Color(0xFFDC2626);
    if (run.isCancelled) return const Color(0xFF6B7280);
    if (run.isSkipped) return const Color(0xFF6B7280);
    return const Color(0xFF6B7280);
  }
}