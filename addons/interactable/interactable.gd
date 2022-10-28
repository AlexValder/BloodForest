tool
extends EditorPlugin


func _enter_tree() -> void:
    add_custom_type(
        "Interactable",
        "Area3D",
        preload("inter_area.gd"),
        preload("hand_icon.png")
    )


func _exit_tree() -> void:
    remove_custom_type("Interactable")
