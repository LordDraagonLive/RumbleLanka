class_name CombatResolver
extends RefCounted
## Collect both contacts before applying either: trades and double KOs are fair.
static func can_block(defender: FighterState, attacker: FighterState, move: AttackDefinition, stage: StageDefinition) -> bool:
	if not defender.grounded(stage) or not defender.guarding:
		return false
	if defender.state not in [FighterState.State.BLOCK, FighterState.State.BLOCKSTUN]:
		return false
	if (attacker.position.x - defender.position.x) * defender.facing < 0:
		return false
	match move.hit_level:
		"throw": return false
		"low": return defender.crouching
		"high", "overhead": return not defender.crouching
	return true

static func resolve(fighters: Array[FighterState], stage: StageDefinition) -> Array[Dictionary]:
	var contacts: Array[Dictionary] = []
	for index in range(2):
		var attacker: FighterState = fighters[index]
		var defender: FighterState = fighters[1 - index]
		if not attacker.active() or attacker.hit_victims.has(defender.player_id):
			continue
		if defender.hp <= 0 or defender.invulnerable():
			continue
		if attacker.attack.hit_level == "throw" and (not defender.grounded(stage) or defender.state in [FighterState.State.HITSTUN, FighterState.State.BLOCKSTUN, FighterState.State.KNOCKDOWN, FighterState.State.GETUP]):
			continue
		if attacker.world_hitbox().intersects(defender.hurtbox()):
			contacts.append({"attacker": attacker, "defender": defender, "move": attacker.attack, "blocked": can_block(defender, attacker, attacker.attack, stage), "direction": attacker.facing})
	var events: Array[Dictionary] = []
	for contact in contacts:
		var attacker: FighterState = contact.attacker
		var defender: FighterState = contact.defender
		var move: AttackDefinition = contact.move
		var blocked: bool = contact.blocked
		attacker.hit_victims[defender.player_id] = true
		var damage: int = 0 if blocked else move.damage
		defender.hp = clampi(defender.hp - damage, 0, maxi(1, defender.definition.health))
		defender.attack = null
		defender.velocity.x = 0.0
		defender.clear_input()
		if defender.hp == 0:
			defender.state = FighterState.State.KO
			defender.guarding = false
		elif blocked:
			defender.state = FighterState.State.BLOCKSTUN
			defender.state_ticks = move.blockstun_ticks
		else:
			defender.guarding = false
			defender.state = FighterState.State.KNOCKDOWN if move.knockdown else FighterState.State.HITSTUN
			defender.state_ticks = 35 if move.knockdown else move.hitstun_ticks
		defender.position.x = clampf(defender.position.x + contact.direction * move.knockback * (0.4 if blocked else 1.0), stage.left_bound, stage.right_bound)
		events.append({"attacker": attacker.player_id, "defender": defender.player_id, "attack": move.id, "damage": damage, "blocked": blocked, "hitstop": move.hitstop_ticks})
	return events
