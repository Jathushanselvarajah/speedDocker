extends Node

# Supabase Configuration
const SUPABASE_URL = "https://jvxyhmnavochitywhuds.supabase.co"
const SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp2eHlobW5hdm9jaGl0eXdodWRzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI4MjUwNDksImV4cCI6MjA4ODQwMTA0OX0.DurRiiNVg_WTMaRkmX3bpGlDzahYyA51LZpQyAZVzKA"

# Helper pour construire l'URL de la table highscores
func get_highscores_url() -> String:
	return SUPABASE_URL + "/rest/v1/highscores"

# Headers requis pour les requêtes Supabase
func get_headers() -> PackedStringArray:
	return PackedStringArray([
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY,
		"Content-Type: application/json",
		"Prefer: return=minimal"
	])

# Headers pour les requêtes GET (pas besoin de Content-Type)
func get_read_headers() -> PackedStringArray:
	return PackedStringArray([
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY
	])
