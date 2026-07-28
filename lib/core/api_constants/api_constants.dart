class ApiConstants {
  // static const String mediaBaseUrl = "http://192.168.2.189:7907/api";
  static const String mediaBaseUrl = "https://testhrms.dazzles.in/";
  // static const String mediaBaseUrl = "https://hrms.dazzles.in";

  static const String sendOtp = "/auth/send-otp";
  static const String verifyOtp = "/auth/verify-otp";
  static const String refreshToken = "/auth/refreshtoken";
  static const String dashboard = "/dashboard";
  static const String profile = "/profile";
  static const String attendance = "/attendance";
  static const String leave = "/leave";
  static const String leaveType = "/leave/leavetype";
  static const String appliedLeaves = "/leave/applied";
  static const String approveLeave = "/leave/approve";
  static const String rejectLeave = "/leave/reject";
  static const String blockedLeaveDates = '/leave/dateBlocked';
  static const String upcomingLeaves = '/leave/upcoming';
  static const String changeLeaveRequest = '/leave/changerequest';
  static const String getPendingLeaves = '/leave/getpending';
  static const String approveChangeLeave = '/leave/approvechange';
  static const String rejectChangeLeave = '/leave/rejectchange';
  static const String announcement = '/announcement';
  static const String getApprovedAnnouncements = "/announcement";
  static const String getPendingAnnouncements = "/announcement/pending";
  static const String approveAnnouncement = "/announcement/approve";
  static const String rejectAnnouncement = "/announcement/reject";
  static const String stores = "/stores";
  static const String employeesByStore = "/stores";
  static const String storeEmployees = "/stores/employees";
  static const String usedLeaves = "/leave/used";
  static const String getEmployeeAnnouncements = "/announcement/employee";
  static const String notifications = "/notification";
  static const String designations = "/designations";
  static const String myEmployees = "/team/employees";
  static const String EmployeeAttendance = "/team/employee/{id}/attendance";
  static const String EmployeeLeaves = "/team/employee/{id}/leaves";
  static const String EmployeeUsedLeaves = "/team/employee/{id}/usedleaves";
  static const String EmployeeApplyLeave = "/team/employee/{id}/leave";
  static const String EmployeeUpcomingLeaves = "/team/employee/{id}/upcoming";
  static const String EmployeePendingLeaves =
      "/team/employee/{id}/pendingleave";
  static const String TeamEmployeePendingLeaves = "/team/employee/pendingleave";
  static const String ApproveEmployeeLeave = "/team/employee/approveleave";
  static const String RejectEmployeeLeave = "/team/employee/rejectleave";
  static const String generateQr = '/attendance/generateqr';
  static const String qrStatus = '/attendance/qr';
  static const String attendanceScanQr = '/attendance/scanqr';
  static const String permissions = '/permissions';
  static const String permissionsGenerate = '/permissions/generate';
  static const String permissionsApply = '/permissions/apply';
  static const String attendancePermissionApply = '/attendancepermission/apply';
  static const String attendancePermissionPending =
      '/attendancepermission/pending';
  static const String attendancePermissionApprove =
      '/attendancepermission/approve';
  static const String attendancePermissionReject =
      '/attendancepermission/reject';
  static const String midPermissionPending = '/permissions/pending';
  static const String midPermissionApprove = '/permissions/approve';
  static const String midPermissionReject = '/permissions/reject';
  static const String generateBreakQr = '/break/generate';
  static const String breakQrStatus = '/break/status';
  static const String breakHistory = '/break/history';
}
