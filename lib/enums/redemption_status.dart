// File: lib/enums/redemption_status.dart

enum RedemptionStatus {
  notUsed,
  used,
  expired,
  unknown,
}

// Hàm trợ giúp để parse String từ backend sang enum
RedemptionStatus parseRedemptionStatus(String? status) {
  switch (status?.toUpperCase()) {
    case 'NOT_USED':
      return RedemptionStatus.notUsed;
    case 'USED':
      return RedemptionStatus.used;
    case 'EXPIRED':
      return RedemptionStatus.expired;
    default:
      return RedemptionStatus.unknown;
  }
}