/// Models behind the admin panel: revenue, activity approvals and payment
/// release.
library;

double? _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

int? _toInt(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

/// The two stat cards at the top of the Revenue dashboard.
class RevenueSummary {
  const RevenueSummary({
    this.monthTotal = 0,
    this.yearTotal = 0,
    this.monthGrowthPercent = 0,
    this.bookingCount = 0,
  });

  factory RevenueSummary.fromJson(Map<String, dynamic> json) {
    return RevenueSummary(
      monthTotal: _toDouble(json['monthTotal']) ?? 0,
      yearTotal: _toDouble(json['yearTotal']) ?? 0,
      monthGrowthPercent: _toDouble(json['monthGrowthPercent']) ?? 0,
      bookingCount: _toInt(json['bookingCount']) ?? 0,
    );
  }

  final double monthTotal;
  final double yearTotal;

  /// Month-on-month change, e.g. 12.5 for "+12.5%".
  final double monthGrowthPercent;
  final int bookingCount;
}

/// One bucket of the income growth curve.
class RevenuePoint {
  const RevenuePoint({required this.label, required this.value});

  factory RevenuePoint.fromJson(Map<String, dynamic> json) {
    return RevenuePoint(
      label: '${json['label'] ?? ''}',
      value: _toDouble(json['value']) ?? 0,
    );
  }

  /// X-axis caption, e.g. "M" or "Jan".
  final String label;
  final double value;
}

/// A booking row on the Revenue dashboard.
class AdminBooking {
  const AdminBooking({
    required this.id,
    required this.title,
    this.listingName = '',
    this.category = '',
    this.imageUrl = '',
    this.amount = 0,
    this.dateRange = '',
  });

  factory AdminBooking.fromJson(Map<String, dynamic> json) {
    return AdminBooking(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? json['customerName'] ?? ''}',
      listingName: '${json['listingName'] ?? ''}',
      category: '${json['category'] ?? ''}',
      imageUrl: '${json['imageUrl'] ?? ''}',
      amount: _toDouble(json['amount']) ?? 0,
      dateRange: '${json['dateRange'] ?? ''}',
    );
  }

  final String id;
  final String title;
  final String listingName;
  final String category;
  final String imageUrl;
  final double amount;

  /// "Sep 12 - Sep 14, 2023".
  final String dateRange;
}

/// Whether a submitted activity has been reviewed yet.
enum ActivityStatus { pending, accepted, rejected }

/// An activity awaiting — or past — admin approval.
class AdminActivitySubmission {
  const AdminActivitySubmission({
    required this.id,
    required this.name,
    this.category = '',
    this.imageUrl = '',
    this.ownerName = '',
    this.ownerAvatarUrl = '',
    this.dateRange = '',
    this.status = ActivityStatus.pending,
  });

  factory AdminActivitySubmission.fromJson(Map<String, dynamic> json) {
    return AdminActivitySubmission(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? json['title'] ?? ''}',
      category: '${json['category'] ?? ''}',
      imageUrl: '${json['imageUrl'] ?? ''}',
      ownerName: '${json['ownerName'] ?? json['partnerName'] ?? ''}',
      ownerAvatarUrl: '${json['ownerAvatarUrl'] ?? ''}',
      dateRange: '${json['dateRange'] ?? ''}',
      status: _statusFrom('${json['status'] ?? ''}'),
    );
  }

  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final String ownerName;
  final String ownerAvatarUrl;
  final String dateRange;
  final ActivityStatus status;

  bool get isPending => status == ActivityStatus.pending;

  static ActivityStatus _statusFrom(String value) {
    return switch (value.toLowerCase()) {
      'accepted' || 'approved' => ActivityStatus.accepted,
      'rejected' => ActivityStatus.rejected,
      _ => ActivityStatus.pending,
    };
  }
}

/// How far along a booking's payment is.
///
/// The design shows a three-stop track: nothing paid, advance paid, and paid
/// in full.
enum PaymentStage { pending, advancePaid, completed }

/// A payment-release row.
class PaymentRelease {
  const PaymentRelease({
    required this.id,
    required this.bookingId,
    this.customerName = '',
    this.customerAvatarUrl = '',
    this.stage = PaymentStage.pending,
    this.advanceAmount = 0,
    this.secondAmount = 0,
    this.totalAmount = 0,
    this.date = '',
    this.timeSlot = '',
  });

  factory PaymentRelease.fromJson(Map<String, dynamic> json) {
    return PaymentRelease(
      id: '${json['id'] ?? ''}',
      bookingId: '${json['bookingId'] ?? ''}',
      customerName: '${json['customerName'] ?? ''}',
      customerAvatarUrl: '${json['customerAvatarUrl'] ?? ''}',
      stage: _stageFrom('${json['stage'] ?? json['status'] ?? ''}'),
      advanceAmount: _toDouble(json['advanceAmount']) ?? 0,
      secondAmount: _toDouble(json['secondAmount']) ?? 0,
      totalAmount: _toDouble(json['totalAmount']) ?? 0,
      date: '${json['date'] ?? ''}',
      timeSlot: '${json['timeSlot'] ?? ''}',
    );
  }

  final String id;
  final String bookingId;
  final String customerName;
  final String customerAvatarUrl;
  final PaymentStage stage;
  final double advanceAmount;

  /// The balance due after the advance.
  final double secondAmount;
  final double totalAmount;
  final String date;
  final String timeSlot;

  bool get isCompleted => stage == PaymentStage.completed;

  /// Only a fully paid booking can be expanded into its breakdown.
  bool get canExpand => stage != PaymentStage.pending;

  static PaymentStage _stageFrom(String value) {
    return switch (value.toLowerCase()) {
      'advancepaid' || 'advance_paid' || 'advance' => PaymentStage.advancePaid,
      'completed' || 'paid' => PaymentStage.completed,
      _ => PaymentStage.pending,
    };
  }
}
