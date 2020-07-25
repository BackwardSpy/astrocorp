extends CanvasLayer

export var warp_drive: NodePath
onready var _warp_drive: WarpDrive = get_node(warp_drive)

func _on_LockBeltButton_pressed():
    _warp_drive.lock_destination(WarpDrive.Destination.BELT)

func _on_LockHomeButton_pressed():
    _warp_drive.lock_destination(WarpDrive.Destination.HOME)

func _on_JumpButton_pressed():
    _warp_drive.jump()
