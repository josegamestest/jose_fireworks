local S=minetest.get_translator(minetest.get_current_modname())
--Codigo feito por josegamestest(joseanastacio)
explode_timer = function(self, pos)
	minetest.sound_play("fireworks_booom", {pos = pos, gain = 1, max_hear_distance = 100, loop = false })
		minetest.add_particlespawner({
			amount = 50,
			time = 0.1,
			minpos = pos,
			maxpos = pos,
			minvel = {x = -5, y = 5, z = -5},
			maxvel = {x = 5, y = 10, z = 5},
			minacc = {x = 0, y = -5, z = 0},
			maxacc = {x = 0, y = -10, z = 0},
			minexptime = 1,
			maxexptime = 3,
			minsize = 5,
			maxsize = 10,
			glow=10,
			collisiondetection = false,
			texture = "jose_fireworks_effects.png",
		})
	self.object:remove()
end,
------------------------------------------------------------------------------
------------------------------------------------------------------------------
minetest.register_node("jose_fireworks:firework", {
	paramtype = "light",
	inventory_image = "jose_fireworks.png",
	drawtype = 'nodebox',
	node_box = {
		type = 'fixed',
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, -0.5},--fundo
			{-0.10, 0, -0.5, 0.10, 0, 0.5},--horizontal
			{0, -0.10, -0.5, 0, 0.10, 0.5},--vertical
		}
	}
	,
	tiles = {
	'jose_fireworks.png',
	'jose_fireworks_b.png',
	'jose_fireworks_d.png',
	'jose_fireworks_e.png',
	'jose_fireworks_f.png',
	'jose_fireworks_f.png'
	},
})
------------------------------------------------------------------------------
------------------------------------------------------------------------------
minetest.register_entity("jose_fireworks:firework_entity", {
	timer = 0,
	firework_firetime = 0,
	firework_flytime = 0,
	--glow=10,
	collisionbox = {-0.2, -0.2, -0.2, 0.2, 0.2, 0.2},
	visual = "wielditem",
	visual_size = {x = 0.4, y = 0.4},
	textures = {"jose_fireworks:firework"},
	initial_sprite_basepos = {x = 0, y = 0},
	initial_properties = {
		physical = true,
		collide_with_objects = false,
		speed = 5,
		gravity = 16,
		damage = 0,
		velocity = 5, -- velocidade inicial
  },
	on_activate = function(self, staticdata, dtime_s)
		self.firework_flytime = math.random(13,15)/10
		self._lifetime = 10
		self.timer = 0
		self.object:set_armor_groups({immortal = 1})

		local pos = self.object:getpos()
		local dir = self.object:get_velocity()
		minetest.sound_play("fireworks_launch", {pos = pos, gain = 1, max_hear_distance = 10, loop = false })
		dir = vector.normalize(dir)
		pos.y = pos.y + 0.5
		self.object:setpos(pos)
		self.object:set_velocity(dir)
		self.object:setacceleration({x=dir.x*-3, y=-10, z=dir.z*-3})
		self.object:set_yaw(math.atan2(dir.z, dir.x) + math.pi) -- this line sets the yaw to point towards the velocity vector
	end,

	on_step = function(self, dtime, moveresult)
		local pos = self.object:get_pos()
		self._old_pos = self._old_pos or pos
		local ray = minetest.raycast(self._old_pos, pos, true, true)
		local pointed_thing = ray:next()
		if not self._attached then
			local velocidade = self.object:get_velocity()
			local pitch = math.atan2(velocidade.y, math.sqrt(velocidade.x^2 + velocidade.z^2))
			local yaw=(math.atan2(velocidade.z, velocidade.x) + math.pi/2)
			local roll = (math.atan2(velocidade.y, velocidade.z) + math.pi/2);
			self.object:set_rotation({x = pitch, y = yaw, z = roll})
		end

		minetest.add_particlespawner({
				amount = 2,
				time = 0.05,
				minpos = pos,
				maxpos = pos,
				minvel = vector.new(-0.1,-0.1,-0.1),
				maxvel = vector.new(1,1,1),
				minexptime = 2,
				maxexptime = 3,
				minsize = 0.5,
				maxsize = 3,
				collisiondetection = false,
				vertical = false,
				texture = "jose_fireworks_smoke.png",
		})

		--dano no jogador
		local objects = minetest.get_objects_inside_radius(pos, 1)
		for _,obj in ipairs(objects) do
			if obj:is_player() then
				obj:set_hp(obj:get_hp()-1)
				explode_timer(self, pos)
			end
		end

		--teste de tempo para remover
		self.timer = self.timer + dtime
		self.firework_firetime = self.firework_firetime + dtime
		if self.firework_firetime > (math.random(0,5)+math.pi/2) then
			explode_timer(self, pos)
		end
	end,

})
------------------------------------------------------------------------------
minetest.register_craftitem("jose_fireworks:jose_rocket", {
    description = S("Rocket"),
    inventory_image = "jose_fireworks.png",
    on_use = function(itemstack, user, pointed_thing)
        local player_pos = user:getpos()
        local dir = user:get_look_dir()
        local inv = user:get_inventory()
        local player = user:get_player_name()
        local obj = minetest.add_entity({x=player_pos.x, y=player_pos.y+1.5, z=player_pos.z}, "jose_fireworks:firework_entity")
		obj:set_velocity({x=dir.x*40, y=dir.y*40, z=dir.z*40})
		obj:setacceleration({x=dir.x*-3, y=-10, z=dir.z*-3})
		obj:setyaw(user:get_look_yaw()+math.pi)
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "jose_fireworks:jose_rocket 10",
	recipe = {
		{"default:paper", "default:coal_lump", "default:paper"},
		{"default:paper", "tnt:gunpowder", "default:paper"},
		{"default:paper", "tnt:gunpowder", "default:paper"},
		}
	})
