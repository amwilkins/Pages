class_name SubAct_SpawnActor
extends BaseSubAction

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor):
	var turn_data = que_exe_data.get_current_turn_data()
	var target_key = subaction_data['TargetKey']
	var target = turn_data.targets[target_key]
	if not target is Vector2i:
		return
	var actor_key = subaction_data['ActorKey']
	CombatRootControl.Instance.create_new_actor(
		MainRootNode.actor_libary.get_actor_data(actor_key), 
		actor.FactionIndex,
		MapPos.new(target.x, target.y, 0, 0))