import 'package:fin/core/models/signer.dart';

abstract class SignerIntent {
  const SignerIntent();
}

class LoadAll extends SignerIntent {
  const LoadAll();
}

class CreateSigner extends SignerIntent {
  final Signer signer;
  const CreateSigner(this.signer);
}

class UpdateSigner extends SignerIntent {
  final Signer signer;
  const UpdateSigner(this.signer);
}

class DeleteSigner extends SignerIntent {
  final String id;
  const DeleteSigner(this.id);
}
