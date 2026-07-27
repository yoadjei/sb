import '../models/music_track.dart';

class MusicLibraryRepository {
  static const defaultTracks = [
    MusicTrack(number: 1, title: 'Match Anthem'),
    MusicTrack(number: 2, title: 'Crowd Cheer'),
    MusicTrack(number: 3, title: 'Halftime Groove'),
    MusicTrack(number: 4, title: 'Victory Fanfare'),
    MusicTrack(number: 5, title: 'Warmup Beats'),
  ];

  List<MusicTrack> load() => defaultTracks;
}
