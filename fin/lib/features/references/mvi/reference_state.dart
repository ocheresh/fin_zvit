import 'package:fin/core/models/reference_item.dart';

class ReferenceState {
  final bool loading;
  final Map<String, List<ReferenceItem>> data;
  final String? error;

  const ReferenceState({required this.loading, required this.data, this.error});

  ReferenceState copy({
    bool? loading,
    Map<String, List<ReferenceItem>>? data,
    String? error,
  }) => ReferenceState(
    loading: loading ?? this.loading,
    data: data ?? this.data,
    error: error,
  );

  static ReferenceState initial() =>
      const ReferenceState(loading: false, data: {});
}
