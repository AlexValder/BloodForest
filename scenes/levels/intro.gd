extends Node

func _ready() -> void:
    var res := preload("res://assets/dialogs/intro.tres") as DialogueResource
    DialogueManager.show_example_dialogue_balloon("intro_dialog", res)
