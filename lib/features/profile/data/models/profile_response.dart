class ProfileModel {
  final int status;
  final bool error;
  final String message;
  final ProfileData data;

  ProfileModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      status: json['status'] as int? ?? 0,
      error: json['error'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      data: ProfileData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class ProfileData {
  final String name;
  final String code;
  final String designation;
  final String mobile;
  final String profileImage;
  final String joiningDate;
  final String role;
  final bool profileImageChangeAllowed;
  final StoreData store;

  ProfileData({
    required this.name,
    required this.code,
    required this.designation,
    required this.mobile,
    required this.profileImage,
    required this.joiningDate,
    required this.role,
    required this.store,
    this.profileImageChangeAllowed = false,
  });

  bool get hasProfileImage {
    final raw = profileImage.trim();
    return raw.isNotEmpty && raw.toLowerCase() != 'null';
  }

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      profileImage: json['profileImage'] as String? ?? '',
      joiningDate: json['joiningDate'] as String? ?? '',
      role: json['role'] as String? ?? '',
      profileImageChangeAllowed: json['profileImageChangeAllowed'] == true,
      store: StoreData.fromJson(json['store'] as Map<String, dynamic>? ?? {}),
    );
  }

  ProfileData copyWith({
    String? name,
    String? code,
    String? designation,
    String? mobile,
    String? profileImage,
    String? joiningDate,
    String? role,
    bool? profileImageChangeAllowed,
    StoreData? store,
  }) {
    return ProfileData(
      name: name ?? this.name,
      code: code ?? this.code,
      designation: designation ?? this.designation,
      mobile: mobile ?? this.mobile,
      profileImage: profileImage ?? this.profileImage,
      joiningDate: joiningDate ?? this.joiningDate,
      role: role ?? this.role,
      profileImageChangeAllowed:
          profileImageChangeAllowed ?? this.profileImageChangeAllowed,
      store: store ?? this.store,
    );
  }
}

class StoreData {
  final String name;
  final String shortForm;

  StoreData({required this.name, required this.shortForm});

  factory StoreData.fromJson(Map<String, dynamic> json) {
    return StoreData(
      name: json['name'] as String? ?? '',
      shortForm: json['shortForm'] as String? ?? '',
    );
  }
}
