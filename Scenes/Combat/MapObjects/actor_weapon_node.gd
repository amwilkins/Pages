@tool
class_name ActorWeaponNode
extends Node2D

const LOGGING = false

@export var weapon_sprite:Sprite2D
@export var overhand_weapon_sprite:Sprite2D
@export var hand_name:String
## Ratio between natural Node rotation and custom Sprite rotation
## At rotation_factor = 0, the sprite's rotation will match the nodes
## At roation factor = 1, the sprite's rotation will match custom_rotation
@export var rotation_factor:float:
	set(val):  
		rotation_factor = val
		if self.weapon_sprite:
			var target_rotation:float = (custom_rotation - (self.rotation_degrees * self.scale.x)) * rotation_factor
			if weapon_sprite.rotation_degrees != target_rotation:
				if LOGGING: print("Setting Rotation: cur:%s | cust:%s | fact:%s | result: %s " % [self.rotation_degrees, custom_rotation, rotation_factor, target_rotation])
				self.weapon_sprite.rotation_degrees = target_rotation
				self.overhand_weapon_sprite.rotation_degrees = target_rotation
@export var custom_rotation:int:
	set(val):  
		custom_rotation = val
		if self.weapon_sprite:
			var target_rotation:float = rotation_factor * custom_rotation + self.rotation_degrees 
			if weapon_sprite.rotation_degrees != target_rotation:
				if LOGGING: print("Setting Rotation: " + str(target_rotation))
				self.weapon_sprite.rotation_degrees = target_rotation
				self.overhand_weapon_sprite.rotation_degrees = target_rotation

func set_weapon(weapon:BaseWeaponEquipment):
	var sprite_data:Dictionary = weapon.get_load_val("WeaponSpriteData", {})
	if sprite_data.size() == 0:
		self.visible = false
		return
	else:
		self.visible = true
	
	var sprite_base_path = weapon._def_load_path.path_join(sprite_data.get("SpriteName"))
	var sprite_file = sprite_base_path + ".png"
	var overhand_sprite_file = sprite_base_path + "_OverHand.png"
	
	self.weapon_sprite.texture = SpriteCache.get_sprite(sprite_file)
	self.overhand_weapon_sprite.texture = SpriteCache.get_sprite(overhand_sprite_file)
	
	var offset_arr = sprite_data.get("Offset", [0,0])
	var offset = Vector2i(offset_arr[0], offset_arr[1])
	self.weapon_sprite.offset = offset
	self.overhand_weapon_sprite.offset = offset
	
	custom_rotation = sprite_data.get("Rotation", 0)
	self.weapon_sprite.rotation_degrees = custom_rotation
	self.overhand_weapon_sprite.rotation_degrees = custom_rotation

func on_animation_end(animation_name:String):
	#if animation_name.begins_with("swing_motion_"):
		#self.weapon_sprite.rotation_degrees = _rest_sprite_rotation
		#self.overhand_weapon_sprite.rotation_degrees = _rest_sprite_rotation
	pass

func on_animation_start(animation_name:String):
	#if animation_name.contains(hand_name):
		#self.weapon_sprite.rotation_degrees = 0
		#self.overhand_weapon_sprite.rotation_degrees = 0
	#else:
		#self.weapon_sprite.rotation_degrees = _rest_sprite_rotation
		#self.overhand_weapon_sprite.rotation_degrees = _rest_sprite_rotation
	pass
