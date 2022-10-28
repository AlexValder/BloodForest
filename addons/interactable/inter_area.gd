extends Area
class_name InterArea

enum InterType {
    NONE = 0,
    TEXT = 1,
    ACTION = 2,
    PICKUP = 3,
    KILL = 4,
   }
signal interacted(obj, title, type)

export var title := ""
export(InterType) var type := InterType.NONE

onready var model := get_child(0)


func ray_interacted() -> void:
    emit_signal("interacted", self, title, type)
