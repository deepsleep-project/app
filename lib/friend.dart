class FriendRecord {
  final String username;
  final String userId;
  bool isAsleep;
  int streak;
  List<int> friendTent;

  FriendRecord({
    required this.username,
    required this.userId,
    required this.isAsleep,
    required this.streak,
    required this.friendTent,
  });
}
