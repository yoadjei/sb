class MusicTrack {
  final int number;
  final String title;
  final Duration? duration;

  const MusicTrack({
    required this.number,
    required this.title,
    this.duration,
  });
}
