import '../../../core/models/reestrprop.dart';

class ReestrPropState {
  final bool loading;
  final String? error;
  final List<ReestrProp> items;

  const ReestrPropState({
    this.loading = false,
    this.error,
    this.items = const [],
  });

  ReestrPropState copy({
    bool? loading,
    String? error,
    List<ReestrProp>? items,
  }) => ReestrPropState(
    loading: loading ?? this.loading,
    error: error,
    items: items ?? this.items,
  );
}
