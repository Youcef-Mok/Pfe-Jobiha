/// Filtres UI du recruteur (homepage) — pur Dart, sans Riverpod.
class RecruiterFilters {
  final String? status;
  final String? dateFilter;
  final String? department;
  final String? jobId;
  final bool savedOnly;

  const RecruiterFilters({
    this.status,
    this.dateFilter,
    this.department,
    this.jobId,
    this.savedOnly = false,
  });

  RecruiterFilters copyWith({
    String? status,
    bool clearStatus = false,
    String? dateFilter,
    bool clearDateFilter = false,
    String? department,
    bool clearDepartment = false,
    String? jobId,
    bool clearJobId = false,
    bool? savedOnly,
  }) =>
      RecruiterFilters(
        status: clearStatus ? null : (status ?? this.status),
        dateFilter: clearDateFilter ? null : (dateFilter ?? this.dateFilter),
        department: clearDepartment ? null : (department ?? this.department),
        jobId: clearJobId ? null : (jobId ?? this.jobId),
        savedOnly: savedOnly ?? this.savedOnly,
      );

  bool get isEmpty =>
      status == null &&
      dateFilter == null &&
      department == null &&
      jobId == null &&
      !savedOnly;
}

/// Helpers partagés pour les intervalles de dates affichés dans les overlays.
class RecruiterFilterDates {
  static bool matchesPostedWithin(DateTime postedAt, String? filter) {
    if (filter == null) return true;
    final now = DateTime.now();
    final maxAge = switch (filter) {
      '3 jours' => const Duration(days: 3),
      '1 semaine' => const Duration(days: 7),
      '1 mois' => const Duration(days: 30),
      '3 mois' => const Duration(days: 90),
      '6 mois' => const Duration(days: 180),
      _ => null,
    };
    if (maxAge == null) return true;
    return now.difference(postedAt) <= maxAge;
  }

  static bool matchesMissionDuration(
    DateTime startDate,
    DateTime endDate,
    String? filter,
  ) {
    if (filter == null) return true;
    final duration = endDate.difference(startDate);
    final maxDuration = switch (filter) {
      '1 semaine' => const Duration(days: 7),
      '2 semaines' => const Duration(days: 14),
      '1 mois' => const Duration(days: 30),
      '3 mois' => const Duration(days: 90),
      '6 mois' => const Duration(days: 180),
      _ => null,
    };
    if (maxDuration == null) return true;
    return duration <= maxDuration;
  }

  static bool matchesAppliedAt(DateTime appliedAt, String? filter) {
    if (filter == null) return true;
    final now = DateTime.now();
    if (filter == 'Aujourd\'hui') {
      return appliedAt.year == now.year &&
          appliedAt.month == now.month &&
          appliedAt.day == now.day;
    }
    final maxAge = switch (filter) {
      '3 jours' => const Duration(days: 3),
      '1 semaine' => const Duration(days: 7),
      '1 mois' => const Duration(days: 30),
      _ => null,
    };
    if (maxAge == null) return true;
    return now.difference(appliedAt) <= maxAge;
  }

  static bool matchesInterviewDate(DateTime scheduled, String? filter) {
    if (filter == null) return true;
    final now = DateTime.now();
    if (filter == 'Aujourd\'hui') {
      return scheduled.year == now.year &&
          scheduled.month == now.month &&
          scheduled.day == now.day;
    }
    if (filter == 'Cette semaine') {
      final startOfWeek =
          now.subtract(Duration(days: now.weekday - DateTime.monday));
      final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59));
      return !scheduled.isBefore(startOfWeek) && !scheduled.isAfter(endOfWeek);
    }
    if (filter == 'Ce mois-ci') {
      return scheduled.year == now.year && scheduled.month == now.month;
    }
    if (filter == 'Mois prochain') {
      final nextMonth = DateTime(now.year, now.month + 1);
      return scheduled.year == nextMonth.year &&
          scheduled.month == nextMonth.month;
    }
    return true;
  }
}
