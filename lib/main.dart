import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const FlutterMovieApp());
}

// Main Application Class / คลาสหลักของแอปพลิเคชัน
class FlutterMovieApp extends StatelessWidget {
  const FlutterMovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FLUTTER MOVIE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark, // Dark theme for cinema feel / ธีมมืดเพื่อให้อารมณ์โรงหนัง
        primaryColor: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFF121212), // Deep black / สีดำลึก
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const MovieListScreen(),
    );
  }
}

// Movie Data Model / คลาสสำหรับจัดการข้อมูลภาพยนตร์
class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final double voteAverage;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
  });

  // Convert JSON to Movie object / แปลงข้อมูล JSON ให้เป็นออบเจกต์ Movie
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      overview: json['overview'] ?? 'No description available',
      posterPath: json['poster_path'] ?? '',
      voteAverage: (json['vote_average'] as num).toDouble(),
    );
  }
}

// Main List Screen / หน้าจอแสดงรายการภาพยนตร์
class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  // Replace with your actual TMDB API Key / ใส่ API Key ของคุณที่นี่
  final String apiKey = 'cb4788e8c26456b87aaf9937b6a95146'; 
  List<Movie> movies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  // Fetch data from TMDB API / ฟังก์ชันดึงข้อมูลจาก API ของ TMDB
  Future<void> fetchMovies() async {
    final String url = 'https://api.themoviedb.org/3/movie/upcoming?api_key=$apiKey';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        setState(() {
          movies = results.map((m) => Movie.fromJson(m)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      // Error handling / จัดการกรณีเกิดข้อผิดพลาด
      debugPrint('Error fetching movies: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FLUTTER MOVIE',
          style: TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return MovieCard(movie: movie);
              },
            ),
    );
  }
}

// Custom Movie Card UI / ดีไซน์บัตรรายการภาพยนตร์
class MovieCard extends StatelessWidget {
  final Movie movie;
  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Movie Poster / รูปโปสเตอร์หนัง
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
            child: Image.network(
              'https://image.tmdb.org/t/p/w200${movie.posterPath}',
              width: 100,
              height: 150,
              fit: BoxFit.cover,
              // Placeholder when image is loading / แสดงรูปจำลองขณะรอโหลด
              errorBuilder: (context, error, stackTrace) => Container(
                width: 100,
                color: Colors.grey[800],
                child: const Icon(Icons.movie),
              ),
            ),
          ),
          // Movie Details / รายละเอียดหนัง
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        movie.voteAverage.toString(),
                        style: const TextStyle(color: Colors.amber),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.overview,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}