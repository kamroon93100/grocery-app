import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';
import '../providers/auth_provider.dart';

class ReviewsSection extends StatefulWidget {
  final String productId;
  final double averageRating;
  final int    totalReviews;
  const ReviewsSection({
    super.key,
    required this.productId,
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  List<ReviewModel> _reviews   = [];
  bool              _loading   = true;
  bool              _showAll   = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _loading = true);
    final reviews = await ReviewService().getProductReviews(widget.productId);
    if (mounted) {
      setState(() {
        _reviews = reviews;
        _loading = false;
      });
    }
  }

  Map<int, int> get _ratingDistribution {
    final dist = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final r in _reviews) {
      dist[r.rating] = (dist[r.rating] ?? 0) + 1;
    }
    return dist;
  }

  void _showAddReviewDialog() {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login to add review'),
          backgroundColor: Colors.red));
      return;
    }

    int    rating     = 5;
    final  commentCtrl = TextEditingController();

    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize:       MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Write Review',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                const Text('How would you rate?',
                  style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) =>
                      GestureDetector(
                        onTap: () => setS(() => rating = i + 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            i < rating ? Icons.star : Icons.star_border,
                            size: 50,
                            color: i < rating ? Colors.amber : Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    rating == 1 ? '😞 Poor' :
                    rating == 2 ? '😐 Fair' :
                    rating == 3 ? '🙂 Good' :
                    rating == 4 ? '😊 Very Good' : '🤩 Excellent',
                    style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: commentCtrl,
                  maxLines:    4,
                  maxLength:   500,
                  decoration: InputDecoration(
                    labelText:  'Your Review',
                    hintText:   'Tell others about this product...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width:  double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    icon:  const Icon(Icons.send),
                    label: const Text('Submit Review',
                      style: TextStyle(fontSize: 16)),
                    onPressed: () async {
                      if (commentCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Write a review'),
                            backgroundColor: Colors.red));
                        return;
                      }
                      final result = await ReviewService().addReview(
                        widget.productId,
                        rating,
                        commentCtrl.text.trim(),
                      );
                      if (!context.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['success'] == true
                              ? '⭐ Review submitted!' : result['message'] ?? 'Failed'),
                          backgroundColor: result['success'] == true
                              ? Colors.green : Colors.red,
                        ),
                      );
                      if (result['success'] == true) {
                        _loadReviews();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleReviews = _showAll
        ? _reviews
        : _reviews.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Reviews & Ratings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton.icon(
              icon:  const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Write Review'),
              onPressed: _showAddReviewDialog,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Rating Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:        Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border:       Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              // Big rating
              Column(
                children: [
                  Text(widget.averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 40, fontWeight: FontWeight.bold,
                      color: Colors.amber)),
                  Row(
                    children: List.generate(5, (i) => Icon(
                      i < widget.averageRating.round()
                          ? Icons.star : Icons.star_border,
                      size: 16,
                      color: Colors.amber)),
                  ),
                  const SizedBox(height: 4),
                  Text('${widget.totalReviews} reviews',
                    style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 11)),
                ],
              ),
              const SizedBox(width: 20),
              // Distribution bars
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((star) {
                    final count = _ratingDistribution[star] ?? 0;
                    final percent = widget.totalReviews == 0
                        ? 0.0 : count / widget.totalReviews;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            child: Text('$star',
                              style: const TextStyle(fontSize: 12))),
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 6),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: percent,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation(
                                Colors.amber),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 20,
                            child: Text('$count',
                              style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade600))),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Reviews List
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Colors.green),
            ),
          )
        else if (_reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Icon(Icons.rate_review_outlined,
                  size: 50, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text('No reviews yet',
                  style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text('Be the first to review!',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          )
        else
          Column(
            children: visibleReviews.map((review) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.green,
                        child: Text(
                          review.userName.isNotEmpty
                              ? review.userName[0].toUpperCase() : 'U',
                          style: const TextStyle(color: Colors.white,
                            fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(review.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                                if (review.isVerified) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.verified,
                                    size: 14, color: Colors.green),
                                ],
                              ],
                            ),
                            Row(
                              children: [
                                ...List.generate(5, (i) => Icon(
                                  i < review.rating
                                      ? Icons.star : Icons.star_border,
                                  size: 14,
                                  color: Colors.amber)),
                                const SizedBox(width: 6),
                                Text(
                                  review.createdAt.isNotEmpty
                                      ? review.createdAt.substring(0, 10)
                                      : '',
                                  style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade500)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (review.comment.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(review.comment,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 13, height: 1.4)),
                  ],
                ],
              ),
            )).toList(),
          ),

        // Show More button
        if (_reviews.length > 3)
          Center(
            child: TextButton.icon(
              icon: Icon(_showAll
                  ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
              label: Text(_showAll
                  ? 'Show Less' : 'Show All ${_reviews.length} Reviews'),
              onPressed: () => setState(() => _showAll = !_showAll),
            ),
          ),
      ],
    );
  }
}
