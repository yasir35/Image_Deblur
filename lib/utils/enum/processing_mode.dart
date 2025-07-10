enum ProcessingMode {
  online,
  offline,
  auto, // Automatically choose based on connectivity and model availability
}

extension ProcessingModeExtension on ProcessingMode {
  String get displayName {
    switch (this) {
      case ProcessingMode.online:
        return 'Online (API)';
      case ProcessingMode.offline:
        return 'Offline (Local AI)';
      case ProcessingMode.auto:
        return 'Auto (Smart Choice)';
    }
  }
}