extends GridContainer

export(NodePath) var tracking

onready var _x := $label01 as Label
onready var _y := $label03 as Label
onready var _z := $label05 as Label

var _obj: Spatial

func _ready() -> void:
    var obj := get_node(tracking) as Spatial
    assert(obj, "%s is not Spatial" % str(tracking))
    _obj = obj


func _process(_delta: float) -> void:
    _x.text = str(_obj.global_transform.origin.x)
    _y.text = str(_obj.global_transform.origin.y)
    _z.text = str(_obj.global_transform.origin.z)
