import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/github_issue.dart';
import '../../../data/models/github_comment.dart';
import '../../../data/services/auth_storage.dart';
import '../../../data/services/github_api_service.dart';
import 'edit_issue_screen.dart';

class IssueDetailScreen extends StatefulWidget {
  final String owner;
  final String repoName;
  final int issueNumber;

  const IssueDetailScreen({
    super.key,
    required this.owner,
    required this.repoName,
    required this.issueNumber,
  });

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  GitHubIssue? _issue;
  List<GitHubComment> _comments = [];
  bool _isLoading = true;
  String? _error;
  String? _token;
  bool _isUpdatingState = false;

  final _commentController = TextEditingController();
  bool _isSendingComment = false;

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

    final issue = await GitHubApiService.getIssueDetail(
      _token!,
      widget.owner,
      widget.repoName,
      widget.issueNumber,
    );
    final comments = await GitHubApiService.getIssueComments(
      _token!,
      widget.owner,
      widget.repoName,
      widget.issueNumber,
    );

    if (!mounted) return;
    setState(() {
      _issue = issue;
      _comments = comments;
      _isLoading = false;
    });
  }

  Future<void> _toggleState() async {
    if (_issue == null || _token == null) return;

    final isClosing = _issue!.isOpen;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isClosing ? 'Close Issue' : 'Reopen Issue',
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        content: Text(
          isClosing
              ? 'Yakin mau tutup issue ini?'
              : 'Yakin mau buka lagi issue ini?',
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isClosing
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF10B981),
            ),
            child: Text(isClosing ? 'Close' : 'Reopen'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isUpdatingState = true);

    bool ok;
    if (isClosing) {
      ok = await GitHubApiService.closeIssue(
        _token!,
        widget.owner,
        widget.repoName,
        widget.issueNumber,
      );
    } else {
      ok = await GitHubApiService.reopenIssue(
        _token!,
        widget.owner,
        widget.repoName,
        widget.issueNumber,
      );
    }

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isClosing
              ? 'Issue berhasil ditutup'
              : 'Issue berhasil dibuka lagi'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      _loadAll();
    } else {
      setState(() => _isUpdatingState = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal update status issue'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
    }
  }

  Future<void> _openEdit() async {
    if (_issue == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditIssueScreen(
          owner: widget.owner,
          repoName: widget.repoName,
          issue: _issue!,
        ),
      ),
    );

    if (result == true) _loadAll();
  }

  Future<void> _sendComment() async {
    final body = _commentController.text.trim();
    if (body.isEmpty || _token == null) return;

    setState(() => _isSendingComment = true);

    final comment = await GitHubApiService.createIssueComment(
      _token!,
      widget.owner,
      widget.repoName,
      widget.issueNumber,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Komentar terkirim'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
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

  Future<void> _openInBrowser() async {
    if (_issue?.htmlUrl == null) return;
    final uri = Uri.parse(_issue!.htmlUrl!);
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
        title: Text(
          'Issue #${widget.issueNumber}',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          if (_issue != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_rounded,
                  color: Color(0xFF6366F1), size: 20),
              onPressed: _openEdit,
              tooltip: 'Edit Issue',
            ),
            IconButton(
              icon: Icon(
                _issue!.isOpen
                    ? Icons.check_circle_outline_rounded
                    : Icons.refresh_rounded,
                color: _issue!.isOpen
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF59E0B),
                size: 20,
              ),
              onPressed: _isUpdatingState ? null : _toggleState,
              tooltip: _issue!.isOpen ? 'Close Issue' : 'Reopen Issue',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded,
                color: Color(0xFF6B7280), size: 20),
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
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }

    if (_error != null || _issue == null) {
      return Center(
        child: Text(
          _error ?? 'Issue gak ketemu',
          style: const TextStyle(fontFamily: 'Inter'),
        ),
      );
    }

    final issue = _issue!;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: issue.isOpen
                            ? const Color(0xFF10B981)
                                .withValues(alpha: 0.1)
                            : const Color(0xFFDC2626)
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            issue.isOpen
                                ? Icons.error_outline_rounded
                                : Icons.check_circle_outline_rounded,
                            size: 14,
                            color: issue.isOpen
                                ? const Color(0xFF10B981)
                                : const Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            issue.isOpen ? 'Open' : 'Closed',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: issue.isOpen
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  issue.title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    if (issue.userAvatar != null)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(issue.userAvatar!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      const Icon(Icons.person,
                          size: 18, color: Color(0xFF6B7280)),
                    const SizedBox(width: 8),
                    Text(
                      '@${issue.userLogin ?? 'unknown'}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),

                if (issue.labels.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: issue.labels.map((label) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                if (issue.body != null && issue.body!.isNotEmpty) ...[
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
                      issue.body!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Color(0xFF374151),
                        height: 1.6,
                      ),
                    ),
                  ),
                ],

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
                      color: const Color(0xFF6366F1),
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