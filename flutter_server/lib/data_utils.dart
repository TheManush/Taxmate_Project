// Utility functions to handle potentially invalid data safely

class DataUtils {
  /// Safely gets the first character of a name for avatars
  static String getInitial(String? name, {String fallback = '?'}) {
    if (name == null || name.trim().isEmpty) {
      return fallback;
    }
    return name.trim()[0].toUpperCase();
  }

  /// Safely gets initials from a full name
  static String getInitials(String? name, {String fallback = '??'}) {
    if (name == null || name.trim().isEmpty) {
      return fallback;
    }
    
    List<String> names = name.trim().split(' ').where((n) => n.isNotEmpty).toList();
    if (names.length >= 2 && names[0].isNotEmpty && names[1].isNotEmpty) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty && names[0].isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return fallback;
  }

  /// Safely gets the first name from a full name
  static String getFirstName(String? fullName, {String fallback = 'User'}) {
    if (fullName == null || fullName.trim().isEmpty) {
      return fallback;
    }
    
    final firstName = fullName.trim().split(' ').first;
    return firstName.isNotEmpty ? firstName : fallback;
  }

  /// Validates and cleans a client/user data map
  static Map<String, dynamic> sanitizeUserData(Map<String, dynamic> userData) {
    final sanitized = Map<String, dynamic>.from(userData);
    
    // Ensure full_name is never null or empty
    if (sanitized['full_name'] == null || 
        sanitized['full_name'].toString().trim().isEmpty) {
      sanitized['full_name'] = 'Unknown User';
    }
    
    // Ensure email is never null
    if (sanitized['email'] == null || 
        sanitized['email'].toString().trim().isEmpty) {
      sanitized['email'] = 'no-email@example.com';
    }
    
    // Ensure id exists
    if (sanitized['id'] == null) {
      sanitized['id'] = -1;
    }
    
    return sanitized;
  }

  /// Safely formats a list of client data
  static List<Map<String, dynamic>> sanitizeClientList(List<Map<String, dynamic>> clients) {
    return clients.map((client) => sanitizeUserData(client)).toList();
  }
}
