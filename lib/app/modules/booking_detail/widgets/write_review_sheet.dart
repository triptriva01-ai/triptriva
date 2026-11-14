import 'package:flutter/material.dart';

import '../constants/booking_detail_constants.dart';

/// What [WriteReviewSheet] returns.
class ReviewDraft {
  const ReviewDraft({required this.rating, required this.comment});

  final int rating;
  final String comment;
}

/// Bottom sheet for "Write a Review": five stars and a comment.
///
/// There is no Figma frame for this yet; it borrows the booking detail
/// colours so it can be swapped for the design later.
class WriteReviewSheet extends StatefulWidget {
  const WriteReviewSheet({super.key});

  @override
  State<WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<WriteReviewSheet> {
  final _comment = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  bool get _canSubmit => _rating > 0 && _comment.text.trim().length >= 3;

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                BookingDetailStrings.reviewTitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var star = 1; star <= 5; star++)
                    IconButton(
                      onPressed: () => setState(() => _rating = star),
                      icon: Icon(
                        star <= _rating ? Icons.star : Icons.star_border,
                        size: 34,
                        color: const Color(0xFFFFB300),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _comment,
                onChanged: (_) => setState(() {}),
                maxLines: 4,
                maxLength: 1000,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: BookingDetailStrings.reviewHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _canSubmit
                    ? () => Navigator.of(context).pop(
                          ReviewDraft(
                            rating: _rating,
                            comment: _comment.text.trim(),
                          ),
                        )
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1F7A63),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(BookingDetailStrings.submit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
