class Signer {
  final String id;
  final String position;
  final String rank; // військове звання
  final String signRight;
  final String lastName;
  final String firstName;
  final String fatherName;

  const Signer({
    required this.id,
    required this.position,
    required this.rank,
    required this.signRight,
    required this.lastName,
    required this.firstName,
    required this.fatherName,
  });

  factory Signer.fromJson(Map<String, dynamic> j) => Signer(
    id: j['id'] as String,
    position: j['position'] as String,
    rank: j['rank'] as String,
    signRight: j['signRight'] as String,
    lastName: j['lastName'] as String,
    firstName: j['firstName'] as String,
    fatherName: j['fatherName'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'position': position,
    'rank': rank,
    'signRight': signRight,
    'lastName': lastName,
    'firstName': firstName,
    'fatherName': fatherName,
  };
}
