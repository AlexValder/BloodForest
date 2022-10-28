extends Node

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
const _DB_PATH := "res://assets/data"

var db: SQLite


func _enter_tree() -> void:
	_load_db()


func _load_db() -> void:
	db = SQLite.new()
	db.path = _DB_PATH
	db.verbosity_level = 2 if OS.is_debug_build() else 0
	db.read_only = true

	if !db.open_db():
		push_error("Failed to open database")


func get_item_by_path(path: String) -> Array:
	return get_item("path", path)


func get_item_by_id(id: int) -> Array:
	return get_item("id", str(id))


func get_item(key: String, value: String) -> Array:
	return _get_from_database("items", "%s LIKE '%s'" % [key, value])


func get_items() -> Array:
	return _get_from_database("items")


func get_loading() -> Array:
	return _get_from_database("loading_text")


func _get_from_database(table: String, selector := "", rows := ["*"]) -> Array:
	return db.select_rows(table, selector, rows)
