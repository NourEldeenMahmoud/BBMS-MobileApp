class EligibilityCalculator {
  static bool isEligibleToDonate(DateTime? lastDonationDate) {
    if (lastDonationDate == null) return true;

    final daysSinceLastDonation = DateTime.now().difference(lastDonationDate).inDays;
    return daysSinceLastDonation >= 56; // 56 days minimum between donations
  }

  static DateTime? getNextEligibleDate(DateTime? lastDonationDate) {
    if (lastDonationDate == null) return DateTime.now();
    return lastDonationDate.add(const Duration(days: 56));
  }

  static int calculateLivesSaved(int totalDonations) {
    return totalDonations * 3; // Each donation can save up to 3 lives
  }

  static int daysUntilEligible(DateTime? lastDonationDate) {
    if (lastDonationDate == null) return 0;
    final nextEligible = getNextEligibleDate(lastDonationDate);
    if (nextEligible == null) return 0;
    final difference = nextEligible.difference(DateTime.now()).inDays;
    return difference > 0 ? difference : 0;
  }
}

