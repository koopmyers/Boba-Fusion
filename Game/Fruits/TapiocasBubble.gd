extends RigidBody2D
class_name TapiocaBubble


signal fusionned(bubble_a, bubble_b)


const BASE_RADIUS := 108.0
const PARAMS := [
	{
		"texture": preload("01.tres"),
		"radius": 20,
		"points": 2,
		"color": Color("#fd5eca"),
	},
	
	{
		"texture": preload("02.tres"),
		"radius": 27,
		"points": 3,
		"color": Color("#fbb62d"),
	},
	
	{
		"texture": preload("03.tres"),
		"radius": 36,
		"points": 6,
		"color": Color("#63278b"),
	},
	
	{
		"texture": preload("04.tres"),
		"radius": 47,
		"points": 10,
		"color": Color("#c7d820"),
	},
	
	{
		"texture": preload("05.tres"),
		"radius": 58,
		"points": 15,
		"color": Color("a72653"),
	},
	
	{
		"texture": preload("06.tres"),
		"radius": 71,
		"points": 21,
		"color": Color("#1ccd97"),
	},
	
	{
		"texture": preload("07.tres"),
		"radius": 84,
		"points": 28,
		"color": Color("#f46525"),
	},
	
	{
		"texture": preload("08.tres"),
		"radius": 96,
		"points": 37,
		"color": Color("#48d44f"),
	},
	
	{
		"texture": preload("09.tres"),
		"radius": 106,
		"points": 47,
		"color": Color("#0774b8"),
	},
	
	{
		"texture": preload("10.tres"),
		"radius": 115,
		"points": 58,
		"color": Color("#e1d395"),
	},
	
	{
		"texture": preload("11.tres"),
		"radius": 130,
		"points": 70,
		"color": Color("#531e09"),
	},
]

const FACES := [
	preload("Faces/Shy.tres"),
	preload("Faces/Cool.tres"),
	preload("Faces/Angry.tres"),
]


const FALL_FUSION_IMPULSE := 500
const GROW_DURATION: float = 0.25 # sec
const FUSION_SPEED := 1000

const FALLING_VELOCITY_THRESHOLD: float = 200.0
const CRUSHED_CONTACT_THRESHOLD: int = 4
const ROLLING_VOLOCITY_THRESHOLD: float = 1.5


@export var type: int = 0:
	set(x):
		if not is_type_valid(x):
			push_error("Bubble type not valid")
			return
		
		type = x
		
		var params = PARAMS[type]
		points = params.get("points", points)
		
		radius = params.get("radius", radius)
		color = params.get("color", Color.WHITE)
		
		if not is_inside_tree():
			return
		
		sprite.texture = params.get("texture")
		size = 0.0

var points := 1
var radius: float = 27:
	set(x):
		radius = x
		face_ratio = float(radius/BASE_RADIUS)
		mass = float(radius)
		
		if not is_inside_tree():
			return
		
		scaler.scale = face_ratio * Vector2.ONE
		
		var shape := CircleShape2D.new()
		shape.radius = radius
		collision_shape.set_deferred("shape", shape)
		
		particules.scale_amount_min = face_ratio
		particules.scale_amount_max = face_ratio


var color: Color = Color.REBECCA_PURPLE:
	set(x):
		color = x
		
		if not is_inside_tree():
			return
		
		particules.modulate = color


var face_ratio := 1.0
var size := 0.0:
	set(x):
		sprite.scale = x * Vector2.ONE
		scaler.scale = x * face_ratio * Vector2.ONE
		collision_shape.shape.radius = radius * x


var fluid_density: float = 0.0
var physic_activated := false:
	set(x):
		physic_activated = x
		if x:
			max_contacts_reported = 4
			contact_monitor = true
			set_collision_layer_value(1, true)
			set_collision_mask_value(1, true)
			freeze = false
		
		else:
			max_contacts_reported = 0
			contact_monitor = false
			set_collision_layer_value(1, false)
			set_collision_mask_value(1, false)
			freeze = true


var is_fusionned := false
var invincible := true

var falling := false
var rolling := false
var crushed := false
var in_danger := false

@onready var animation_player := $AnimationPlayer
@onready var invincibility_timer := $Timer
@onready var scaler := $Scaler
@onready var sprite := $Sprite2D
@onready var animated_face := $Scaler/Face
@onready var collision_shape := $CollisionShape2D

@onready var particules := $Particles2D
@onready var audio_player_a := $AudioStreamPlayer2DA
@onready var audio_player_b := $AudioStreamPlayer2DB


static func is_type_valid(p_type: int) -> bool:
	return 0 <= p_type and p_type < len(PARAMS) 


static func get_texture(p_type: int) -> Texture2D:
	if not is_type_valid(p_type):
			push_error("Bubble type not valid")
			return null
	
	var params = PARAMS[p_type]
	return params.get("texture")


static func get_color(p_type: int) -> Color:
	if not is_type_valid(p_type):
			push_error("Bubble type not valid")
			return Color.RED
	
	var params = PARAMS[p_type]
	return params.get("color")


func _ready():
	physic_activated = false
	animation_player.play("RESET")
	animated_face.frames = FACES[randi() % len(FACES)]


func get_collision_shape() -> Shape2D:
	return collision_shape.shape


func get_evolution_type() -> int:
	return (type + 1) % len(PARAMS)


func grow(from_fusion := false):
	
	if from_fusion:
		audio_player_a.pitch_scale = randf_range(0.95, 1.05)
		audio_player_b.pitch_scale = randf_range(0.98, 1.02)
		animation_player.play("fusion")
	
	var tween := get_tree().create_tween()
	tween.tween_property(self, "size", 1.0, GROW_DURATION
		).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished


func fall(impulse: int = 1):
	set_deferred("physic_activated", true)
	apply_central_impulse(mass * impulse * Vector2.DOWN) # small impulse to feel gravity again
	invincibility_timer.start()


func _on_invincibility_timeout():
	invincible = false


func pop():
	set_deferred("physic_activated", false)
	
	audio_player_a.pitch_scale = randf_range(0.95, 1.05)
	animation_player.play("pop")
	await animation_player.animation_finished


func delete(pos: Vector2 = global_position):
	set_deferred("physic_activated", false)
	
	var distance := global_position.distance_to(pos)
	var time := distance/FUSION_SPEED
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", pos, time)
	await tween.finished
	queue_free()


func evolve(pos: Vector2 = global_position):
	set_deferred("physic_activated", false)
	
	var distance := global_position.distance_to(pos)
	var time := distance/FUSION_SPEED
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", pos, time)
	await tween.finished
	
	type = get_evolution_type()
	set_deferred("physic_activated", true)
	is_fusionned = false
	
	fall(FALL_FUSION_IMPULSE)
	await grow(true)


func _process(_delta):
	
	if falling:
		animated_face.play("falling")
	
	elif rolling:
		animated_face.play("rolling")
	
	elif crushed:
		animated_face.play("crushed")
	
	elif in_danger:
		animated_face.play("in_danger")
	
	else:
		animated_face.play("idle")


func _integrate_forces(state: PhysicsDirectBodyState2D):
	falling = bool(state.linear_velocity.y > FALLING_VELOCITY_THRESHOLD)
	crushed = bool(state.get_contact_count() >= CRUSHED_CONTACT_THRESHOLD)
	rolling = bool(abs(state.angular_velocity) > ROLLING_VOLOCITY_THRESHOLD)
	
	var A = radius*2.0
	var Cd = 0.01
	var drag = -0.5*fluid_density*state.linear_velocity*abs(state.linear_velocity)*A*Cd
	state.apply_central_force(drag)
	
	var angular_drag = -0.5*fluid_density*state.angular_velocity*abs(state.angular_velocity)*A*Cd
	state.apply_torque(angular_drag)
	

func _on_body_entered(body):
	
	if not body is TapiocaBubble:
		return
	
	if body.type != type: # same type of bubbles
		return
	
	if body.name > name: # only one body raise the collision
		return
	
	if is_fusionned: # don't fusion with another in the mean time
		return
	
	fusion_with_other(body)


func fusion_with_other(other: TapiocaBubble):
	is_fusionned = true
	other.is_fusionned = true
	fusionned.emit(self, other)
	
	var pos: Vector2 = (global_position + other.global_position) * 0.5 # center betwen two points
	
	other.delete(pos)
	await evolve(pos)
