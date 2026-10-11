import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/github_pr.dart';
import '../../../data/models/github_comment.dart';
import '../../../data/models/github_review.dart';
import '../../../data/services/auth_storage.dart';
import '../../../data/services/github_api_service.dart';

class PRDetailScreen extends StatefulWidget {
  final String owner;
  final String repoName;
  final int prNumber;

  const PRDetailScreen({
    super.key,
    required this.owner,
    required this.repoName,
    required this.prNumber,
  });

  @override
  State<PRDetailScreen> createState() => _PRDetailScreenState();
}

class _PRDetailScreenState extends State<PRDetailScreen> {
  GitHubPR? _pr;
  List<GitHubComment> _comments = [];
  List<GitHubReview> _reviews = [];
  bool _isLoading = true;
  String? _error;
  String? _token;

  final _commentController = TextEditingController();
  bool _isSendingComment = false;
  bool _isMerging = false;
  bool _isSubmittingReview = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _commentController.dispose();
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

    final pr = await GitHubApiService.getPRDetail(
      _token!,
      widget.owner,
      widget.repoName,
      widget.prNumber,
    );
    final comments = await GitHubApiService.getIssueComments(
      _token!,
      widget.owner,
      widget.repoName,
      widget.prNumber,
    );
    final reviews = await GitHubApiService.getPRReviews(
      _token!,
      widget.owner,
      widget.repoName,
      widget.prNumber,
    );

    if (!mounted) return;
    setState(() {
      _pr = pr;
      _comments = comments;
      _reviews = reviews;
      _isLoading = false;
    });
  }

  Future<void> _sendComment() async {
    final body = _commentController.text.trim();
    if (body.isEmpty || _token == null) return;

    setState(() => _isSendingComment = true);

    final comment = await GitHubApiService.createIssueComment(
      _token!,
      widget.owner,
      widget.repoName,
      widget.prNumber,
      body,
    );

    if (!mounted) return;

    if (comment != null) {
      _commentController.clear();
      setState(() {
        _comments = [..._comments, comment];
        _isSendingComment = false;
      });
      FocusScope.of(context).unfocus();
    } else {
      setState(() => _isSendingComment = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal kirim komentar'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
    }
  }

  Future<void> _mergePR() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Merge Pull Request',
            style: TextStyle(fontFamily: 'Inter')),
        content: const Text(
          'Yakin mau merge PR ini ke base branch?',
          style: TextStyle(fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
            ),
            child: const Text('Merge'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isMerging = true);

    final ok = await GitHubApiService.mergePR(
      _token!,
      widget.owner,
      widget.repoName,
      widget.prNumber,
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PR berhasil di-merge'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      _loadAll();
    } else {
      setState(() => _isMerging = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal merge PR. Cek konflik.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
    }
  }

  Future<void> _submitReview(String event) async {
    if (_token == null) return;

    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          event == 'APPROVE'
              ? 'Approve Pull Request'
              : event == 'REQUEST_CHANGES'
                  ? 'Request Changes'
                  : 'Comment Review',
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              event == 'APPROVE'
                  ? 'Setujui PR ini?'
                  : event == 'REQUEST_CHANGES'
                      ? 'Minta perubahan pada PR ini?'
                      : 'Tulis komentar review:',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                controller: controller,
                maxLines: 4,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Color(0xFF111827),
                ),
                decoration: const InputDecoration(
                  hintText: 'Komentar (opsional)',
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: event == 'APPROVE'
                  ? const Color(0xFF10B981)
                  : event == 'REQUEST_CHANGES'
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF6366F1),
            ),
            child: Text(
              event == 'APPROVE'
                  ? 'Approve'
                  : event == 'REQUEST_CHANGES'
                      ? 'Request'
                      : 'Submit',
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmittingReview = true);

    final ok = await GitHubApiService.submitPRReview(
      _token!,
      widget.owner,
      widget.repoName,
      widget.prNumber,
      event: event,
      body: controller.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review berhasil dikirim'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      _loadAll();
    } else {
      setState(() => _isSubmittingReview = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal kirim review'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
    }
  }

  Future<void> _openInBrowser() async {
    if (_pr?.htmlUrl == null) return;
    final uri = Uri.parse(_pr!.htmlUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Color _statusColor() {
    if (_pr == null) return const Color(0xFF6B7280);
    if (_pr!.isMerged) return const Color(0xFF8B5CF6);
    if (_pr!.isClosed) return const Color(0xFFDC2626);
    if (_pr!.draft) return const Color(0xFF6B7280);
    return const Color(0xFF10B981);
  }

  IconData _statusIcon() {
    if (_pr == null) return Icons.merge_type_rounded;
    if (_pr!.isMerged) return Icons.check_circle_rounded;
    if (_pr!.isClosed) return Icons.cancel_rounded;
    if (_pr!.draft) return Icons.edit_note_rounded;
    return Icons.merge_type_rounded;
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
          'PR #${widget.prNumber}',
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
                color: Color(0xFF8B5CF6), size: 20),
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
        child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
      );
    }

    if (_error != null || _pr == null) {
      return Center(
        child: Text(
          _error ?? 'PR gak ketemu',
          style: const TextStyle(fontFamily: 'Inter'),
        ),
      );
    }

    final pr = _pr!;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(), size: 14, color: _statusColor()),
                      const SizedBox(width: 6),
                      Text(
                        pr.statusLabel,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _statusColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  pr.title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Author + date
                Row(
                  children: [
                    if (pr.userAvatar != null)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(pr.userAvatar!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      const Icon(Icons.person,
                          size: 18, color: Color(0xFF6B7280)),
                    const SizedBox(width: 8),
                    Text(
                      '@${pr.userLogin ?? 'unknown'}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'тАв ${pr.formattedDate}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),

                // Branch info
                if (pr.headBranch != null && pr.baseBranch != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            pr.headBranch!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8B5CF6),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.arrow_forward_rounded,
                              size: 14, color: Color(0xFF6B7280)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            pr.baseBranch!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Stats
                const SizedBox(height: 16),
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
                          Icons.add_circle_outline_rounded,
                          '+${pr.additions}',
                          const Color(0xFF10B981),
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          Icons.remove_circle_outline_rounded,
                          '-${pr.deletions}',
                          const Color(0xFFDC2626),
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          Icons.description_outlined,
                          '${pr.changedFiles}',
                          const Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                ),

                // Body
                if (pr.body != null && pr.body!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Text(
                      pr.body!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Color(0xFF374151),
                        height: 1.6,
                      ),
                    ),
                  ),
                ],

                // Merge button
                if (pr.isOpen) ...[
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _isMerging ? null : _mergePR,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isMerging)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          else
                            const Icon(Icons.merge_type_rounded,
                                color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Merge Pull Request',
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
                  const SizedBox(height: 10),
                  // 3 tombol review
                  Row(
                    children: [
                      Expanded(
                        child: _buildReviewButton(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'Approve',
                          color: const Color(0xFF10B981),
                          onTap: () => _submitReview('APPROVE'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildReviewButton(
                          icon: Icons.change_circle_outlined,
                          label: 'Request',
                          color: const Color(0xFFDC2626),
                          onTap: () => _submitReview('REQUEST_CHANGES'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildReviewButton(
                          icon: Icons.comment_outlined,
                          label: 'Comment',
                          color: const Color(0xFF6366F1),
                          onTap: () => _submitReview('COMMENT'),
                        ),
                      ),
                    ],
                  ),
                ],

                // Reviews section
                if (_reviews.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Text(
                        'Reviews',
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
                          '${_reviews.length}',
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
                  ..._reviews.map((r) => _buildReviewCard(r)),
                ],

                // Comments
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Text(
                      'Comments',
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
                        '${_comments.length}',
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

                if (_comments.isEmpty)
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
                        'Belum ada komentar',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  )
                else
                  ..._comments.map((c) => _buildCommentCard(c)),
              ],
            ),
          ),
        ),

        // Comment input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: TextField(
                      controller: _commentController,
                      maxLines: 4,
                      minLines: 1,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Color(0xFF111827),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Tulis komentar...',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Color(0xFF9CA3AF),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _isSendingComment ? null : _sendComment,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _isSendingComment
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
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
      ],
    );
  }

  Widget _buildReviewButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isSubmittingReview ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(GitHubReview review) {
    final color = review.isApproved
        ? const Color(0xFF10B981)
        : review.isChangesRequested
            ? const Color(0xFFDC2626)
            : const Color(0xFF6366F1);

    final icon = review.isApproved
        ? Icons.check_circle_outline_rounded
        : review.isChangesRequested
            ? Icons.change_circle_outlined
            : Icons.comment_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (review.userAvatar != null)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(review.userAvatar!),
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
                  '@${review.userLogin ?? 'unknown'}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 10, color: color),
                    const SizedBox(width: 3),
                    Text(
                      review.statusLabel,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.body != null && review.body!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.body!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Color(0xFF374151),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentCard(GitHubComment c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
              if (c.userAvatar != null)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(c.userAvatar!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                const Icon(Icons.person,
                    size: 18, color: Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '@${c.userLogin ?? 'unknown'}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Text(
                c.formattedDate,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          if (c.body != null && c.body!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              c.body!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Color(0xFF374151),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}