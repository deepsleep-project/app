class FriendRecord {
  final String username;
  final String userId;
  bool isAsleep;
  int strike = 0;

  FriendRecord({
    required this.username,
    required this.userId,
    required this.isAsleep,
    required strike,
  });
}
