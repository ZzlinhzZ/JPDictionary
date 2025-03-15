import 'package:flutter/material.dart';
import '../models/kanji_model.dart';
import '../services/api_service.dart';
import 'auth_screen.dart';

class KanjiScreen extends StatefulWidget {
  final List<Kanji> kanjiList;
  final String searchQuery;

  const KanjiScreen({
    required this.kanjiList,
    required this.searchQuery,
    Key? key,
  }) : super(key: key);

  @override
  _KanjiScreenState createState() => _KanjiScreenState();
}

class _KanjiScreenState extends State<KanjiScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController _commentController = TextEditingController();

  Set<String> savedKanji = {};
  Kanji? selectedKanji;
  List<dynamic> comments = [];
  int currentPage = 1;
  int totalPages = 1;
  bool isLoadingComments = false;
  bool isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _loadSavedKanji();
  }

  Future<void> _loadSavedKanji() async {
    try {
      final savedKanjiList = await apiService.getSavedKanji();
      setState(() {
        savedKanji = savedKanjiList.map((k) => k['kanji'] as String).toSet();
      });
    } catch (e) {
      _showErrorDialog('Failed to load saved kanji');
    }
  }

  Future<void> _loadComments() async {
    if (selectedKanji == null) return;

    setState(() => isLoadingComments = true);
    try {
      final response =
          await apiService.getComments(selectedKanji!.kanji, currentPage);
      setState(() {
        comments = response['comments'];
        totalPages = response['total_pages'];
      });
    } catch (e) {
      _showErrorDialog('Failed to load comments');
    } finally {
      setState(() => isLoadingComments = false);
    }
  }

  void _handleKanjiSelection(Kanji kanji) {
    setState(() {
      selectedKanji = kanji;
      currentPage = 1;
    });
    _loadComments();
  }

  Future<void> _toggleSaveKanji(Kanji kanji) async {
    if (!await apiService.isLoggedIn()) {
      _showLoginRequiredDialog();
      return;
    }

    try {
      if (savedKanji.contains(kanji.kanji)) {
        await apiService.removeKanji(kanji.kanji);
        setState(() => savedKanji.remove(kanji.kanji));
      } else {
        await apiService.saveKanji(
          kanji.kanji,
          kanji.kunReadings ?? "",
          kanji.meanings ?? "",
        );
        setState(() => savedKanji.add(kanji.kanji));
      }
    } catch (e) {
      _showErrorDialog('Failed to save kanji');
    }
  }

  Future<void> _submitComment() async {
    if (!await apiService.isLoggedIn()) {
      _showLoginRequiredDialog();
      return;
    }

    if (_commentController.text.isEmpty) return;

    setState(() => isSubmittingComment = true);
    try {
      await apiService.addComment(
          selectedKanji!.kanji, _commentController.text);
      _commentController.clear();
      await _loadComments();
    } catch (e) {
      _showErrorDialog('Failed to submit comment');
    } finally {
      setState(() => isSubmittingComment = false);
    }
  }

  Future<void> _handleVote(int commentId, String action) async {
    if (!await apiService.isLoggedIn()) {
      _showLoginRequiredDialog();
      return;
    }

    try {
      final currentVote =
          comments.firstWhere((c) => c['id'] == commentId)['user_vote'];

      if (currentVote == action) {
        // Hủy vote nếu trùng action
        await apiService.voteComment(commentId, 'un$action');
      } else {
        await apiService.voteComment(commentId, action);
      }
      await _loadComments();
    } catch (e) {
      print("Error voting: $e");
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Log in to use this feature'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                  ctx, MaterialPageRoute(builder: (_) => const AuthScreen()));
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildKanjiList() {
    final queryKanji = widget.searchQuery.split('');
    final filteredKanji =
        widget.kanjiList.where((k) => queryKanji.contains(k.kanji)).toList();

    return Container(
      width: 100,
      color: Colors.grey[200],
      child: ListView.builder(
        itemCount: filteredKanji.length,
        itemBuilder: (ctx, index) => TextButton(
          onPressed: () => _handleKanjiSelection(filteredKanji[index]),
          child: Text(
            filteredKanji[index].kanji,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: selectedKanji == filteredKanji[index]
                  ? Colors.blue
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKanjiDetails() {
    if (selectedKanji == null) {
      return const Center(
        child: Text(
          "Please select a kanji to see its details.",
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailHeader(),
          const SizedBox(height: 24),
          _buildCommentSection(),
        ],
      ),
    );
  }

  Widget _buildDetailHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          selectedKanji!.kanji,
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildDetailItem('Meanings:', selectedKanji!.meanings),
        _buildDetailItem('Kunyomi:', selectedKanji!.kunReadings),
        _buildDetailItem('Onyomi:', selectedKanji!.onReadings),
        _buildDetailItem(
            'Stroke count:', selectedKanji!.strokeCount.toString()),
        const SizedBox(height: 16),
        IconButton(
          icon: Icon(
            savedKanji.contains(selectedKanji!.kanji)
                ? Icons.bookmark
                : Icons.bookmark_border,
            color: savedKanji.contains(selectedKanji!.kanji)
                ? Colors.blue
                : Colors.grey,
          ),
          onPressed: () => _toggleSaveKanji(selectedKanji!),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value ?? "without meaning"),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteButton(
      Map<String, dynamic> comment, String action, IconData icon) {
    final isActive = comment['user_vote'] == action;
    final count = comment[action == 'like' ? 'likes' : 'dislikes'];

    return Row(
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: isActive ? Colors.blue : Colors.grey,
          ),
          onPressed: () => _handleVote(comment['id'], action),
        ),
        Text(count.toString()),
      ],
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comments',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildCommentList(),
        _buildPaginationControls(),
        const SizedBox(height: 24),
        _buildCommentInput(),
      ],
    );
  }

  Widget _buildCommentList() {
    if (isLoadingComments) {
      return const Center(child: CircularProgressIndicator());
    }

    if (comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('No comments yet'),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) => _buildCommentCard(comments[index]),
    );
  }

  Widget _buildCommentCard(Map<String, dynamic> comment) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment['username'] ?? 'Anonymous',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      comment['created_at'] ?? '',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(comment['content']),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.thumb_up,
                    color: comment['user_vote'] == 'like'
                        ? Colors.blue
                        : Colors.grey,
                  ),
                  onPressed: () => _handleVote(comment['id'], 'like'),
                ),
                Text(comment['likes'].toString()),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(
                    Icons.thumb_down,
                    color: comment['user_vote'] == 'dislike'
                        ? Colors.blue
                        : Colors.grey,
                  ),
                  onPressed: () => _handleVote(comment['id'], 'dislike'),
                ),
                Text(comment['dislikes'].toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 1
                ? () {
                    setState(() => currentPage--);
                    _loadComments();
                  }
                : null,
          ),
          Text('Page $currentPage/$totalPages'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages
                ? () {
                    setState(() => currentPage++);
                    _loadComments();
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return FutureBuilder<bool>(
      future: apiService.isLoggedIn(),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData || !snapshot.data!) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Write a comment...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: isSubmittingComment
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                  onPressed: isSubmittingComment ? null : _submitComment,
                ),
              ),
              maxLines: 3,
              minLines: 1,
            ),
            const SizedBox(height: 8),
            const Text(
              'Press Enter to go downline, press the submit button to post',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kanji'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKanjiList(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildKanjiDetails(),
            ),
          ),
        ],
      ),
    );
  }
}
