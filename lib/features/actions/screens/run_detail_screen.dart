import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/github_action.dart';
import '../../../data/services/auth_storage.dart';
import '../../../data/services/github_api_service.dart';

class RunDetailScreen extends StatefulWidget {
  final String owner;
  final String repoName;
  final GitHubWorkflowRun run;

  const RunDetailScreen({
    super.key,
    required this.owner,
    required this.repoName,
    required this.run,
  });

  @override
  State<RunDetailScreen> createState() => _RunDetailScreenState();
}

class _RunDetailScreenState extends State<RunDetailScreen> {
  List<GitHubWorkflowJob> _jobs = [];
  bool _isLoading = true;
  String? _error;

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

    final jobs = await GitHubApiService.getWorkflowRunJobs(
      token,
      widget.owner,
      widget.repoName,
      widget.run.id,
    );

    if (!mounted) return;
    setState(() {
      _jobs = jobs;
      _isLoading = false;
    });
  }

  Future<void> _openInBrowser() async {
    if (widget.run.htmlUrl == null) return;
    final uri = Uri.parse(widget.run.htmlUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final run = widget.run;

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
          'Run #${run.runNumber ?? '-'}',
          style: const TextStyle(
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
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Color(0xFF6366F1), size: 22),
            onPressed: _load,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _statusColor(run).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _statusColor(run).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _statusColor(run).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _statusIcon(run),
                      color: _statusColor(run),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          run.statusLabel,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _statusColor(run),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          run.name ?? 'Workflow',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.account_tree_outlined,
                    'Branch',
                    run.headBranch ?? '-',
                  ),
                  _buildInfoRow(
                    Icons.tag_rounded,
                    'Commit',
                    run.shortSha,
                  ),
                  _buildInfoRow(
                    Icons.bolt_rounded,
                    'Event',
                    run.event ?? '-',
                  ),
                  _buildInfoRow(
                    Icons.timer_outlined,
                    'Duration',
                    run.duration,
                  ),
                  _buildInfoRow(
                    Icons.calendar_today_rounded,
                    'Finished',
                    run.formattedDate,
                  ),
                  _buildInfoRow(
                    Icons.person_outline_rounded,
                    'Actor',
                    run.actorLogin ?? 'unknown',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Jobs section
            Row(
              children: [
                const Text(
                  'Jobs',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(width: 8),
                if (!_isLoading)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_jobs.length}',
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

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                ),
              )
            else if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),
              )
            else if (_jobs.isEmpty)
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
                    'Gak ada job detail',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              )
            else
              ..._jobs.map((job) => _buildJobCard(job)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6B7280)),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(GitHubWorkflowJob job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _jobColor(job).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _jobIcon(job),
              size: 16,
              color: _jobColor(job),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.name,
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
                Text(
                  job.statusLabel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _jobColor(job),
                  ),
                ),
              ],
            ),
          ),
          if (job.htmlUrl != null)
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(job.htmlUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri,
                      mode: LaunchMode.externalApplication);
                }
              },
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
    return const Color(0xFF6B7280);
  }

  IconData _jobIcon(GitHubWorkflowJob job) {
    if (job.isInProgress) {
      return job.status == 'queued'
          ? Icons.schedule_rounded
          : Icons.sync_rounded;
    }
    if (job.isSuccess) return Icons.check_circle_rounded;
    if (job.isFailure) return Icons.cancel_rounded;
    return Icons.help_outline_rounded;
  }

  Color _jobColor(GitHubWorkflowJob job) {
    if (job.isInProgress) return const Color(0xFFF59E0B);
    if (job.isSuccess) return const Color(0xFF10B981);
    if (job.isFailure) return const Color(0xFFDC2626);
    return const Color(0xFF6B7280);
  }
}