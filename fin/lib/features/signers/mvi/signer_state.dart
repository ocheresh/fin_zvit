import 'package:fin/core/models/signer.dart';

class SignerState {
  final bool loading;
  final String? error;
  final List<Signer> items;

  const SignerState({this.loading = false, this.error, this.items = const []});

  SignerState copy({bool? loading, String? error, List<Signer>? items}) =>
      SignerState(
        loading: loading ?? this.loading,
        error: error,
        items: items ?? this.items,
      );
}
