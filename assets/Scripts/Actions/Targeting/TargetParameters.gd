class_name TargetParameters

enum TargetTypes {Self, Spot, OpenSpot, Actor, Ally, Enemy}

var target_key:String
var target_type:TargetTypes
var line_of_sight:bool
var target_area:AreaMatrix
var effect_area:AreaMatrix

func _init(target_key:String, args:Dictionary) -> void:
	# Assign Target Key
	self.target_key = target_key
	
	# Get Target Type
	if args['TargetType'] is int:
		target_type = args['TargetType']
	elif args['TargetType'] is String:
		var temp_type = TargetTypes.get(args['TargetType'])
		if temp_type >= 0:
			target_type = temp_type
		else: 
			printerr("Unknown Target Type: " + args['TargetType'])
		
	# Requires Line of Sight
	line_of_sight = args.get('LineOfSight', true)
	
	# Get Targeting Area
	if args.has('TargetAreaKey'):
		#TODO
		target_area = AreaMatrix.new([[0,0]])
	else:
		target_area = AreaMatrix.new(args['TargetArea'])
	
	if args.has('EffectArea'):
		effect_area = AreaMatrix.new(args['EffectArea'])
	else:
		effect_area = null

func has_area_of_effect()->bool:
	if effect_area:
		return true
	return false

func get_area_of_effect(center:MapPos):
	return effect_area.to_map_spots(center)

func is_spot_target_type()->bool:
	return (self.target_type == TargetTypes.Spot or 
			self.target_type == TargetTypes.OpenSpot)

func is_actor_target_type()->bool:
	return (self.target_type == TargetTypes.Actor or 
			self.target_type == TargetTypes.Ally or 
			self.target_type == TargetTypes.Enemy)

func is_point_in_area(center:MapPos, point:Vector2i)->bool:
	return target_area.to_map_spots(center).has(point)

func is_valid_target_actor(actor:BaseActor, target:BaseActor, game_state:GameStateData):
	if target is BaseActor:
		if target.is_dead:
			return false
		if target_type == TargetTypes.Actor:
			return true
		if target_type == TargetTypes.Enemy:
			return actor.FactionIndex != target.FactionIndex
		if target_type == TargetTypes.Ally:
			return actor.FactionIndex == target.FactionIndex
	#if target is Vector2i or target is MapPos:
		#if target_type == TargetTypes.Spot:
			#return true
		#if target_type == TargetTypes.OpenSpot:
			#return (game_state.MapState.get_actors_at_pos(target).size() == 0 and 
				#not game_state.MapState.spot_blocks_los(target))
	return false
	
func get_valid_target_area(center:MapPos, line_of_sight:bool)->Dictionary:
	var spots =  target_area.to_map_spots(center)
	if not line_of_sight:
		return spots
	var los_dict = {}
	for check in spots:
		TargetingHelper.get_line_of_sight_for_spots(center, check, CombatRootControl.Instance.GameState.MapState, los_dict)
	#var valid_list = []
	#for vec in los_dict.keys():
		#if los_dict[vec]:
			#valid_list.append(vec)
	return los_dict
	