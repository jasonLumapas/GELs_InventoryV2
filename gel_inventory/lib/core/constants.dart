class AppConstants {
  static const String appName = "GEL's Inventory";

  /// Set to true to run entirely on local SQLite (no Supabase calls).
  /// Set to false to enable online sync with Supabase.
  static const bool offlineOnly = true;

  // Replace with your actual Supabase project URL and anon key
  static const String supabaseUrl = 'https://bcytplqoildjjznxpltl.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJjeXRwbHFvaWxkamp6bnhwbHRsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAyNTg0NjMsImV4cCI6MjA5NTgzNDQ2M30.ONOs6pck4yP0orWfAp0pXeOB99vNX2L6vFHsWd1rruw';
}
