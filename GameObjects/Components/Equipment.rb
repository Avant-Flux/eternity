module Component
	class Equipment
		HEAD_SLOTS = [:head]
		BODY_SLOTS = [:body, :legs, :feet, :hands]
		WEAPON_SLOTS = [:weapon_right, :weapon_left]
		
		def initialize(window, physics, base_model, base_animation, opts)
			@physics = physics
			@base_model = base_model
			@base_animation = base_animation
			
			@animations = Hash.new
			
			# TODO: Rename variable
			@items = Hash.new
			
			HEAD_SLOTS.each do |slot|
				item_name = opts[slot]
				next unless item_name
				
				item = Item::Head.new window, item_name, @base_model, @physics
				item.equip
				
				@items[slot] = item
			end
			
			WEAPON_SLOTS.each do |slot|
				item_name = opts[slot]
				next unless item_name
				
				# Blender: z up
				# Ogre: z out, y up
				# px = 0 # Off to one side of character
				# py = 0 # Down the arm
				# pz = 1 # Out
				
				px = -0.247874/100
				py = -1.15424/100
				pz = 1.13644/100
				
				item = Item::Weapon.new	window, item_name, @base_model, 
										[px, pz, -py],
										[-88.683, 175.399, -78.193]
				
				item.equip_to case slot
					when :weapon_right
						:right
					when :weapon_left
						:left
					else
						raise "Weapon must go in either right or left hand"
				end
				
				@items[slot] = item
				
				opts.delete slot
			end
			
			BODY_SLOTS.each do |slot|
				item_name = opts[slot]
				next unless item_name
				
				# These are non-weapons, items which have the Armor interface
				klass = Item.const_get slot.to_s.capitalize.to_sym
				
				@items[slot] = klass.new window, item_name, @physics
			end
		end
		
		def update(dt)
			@items.each_value do |i|
				i.update dt
				
				if i.respond_to? :sync_animation
					i.sync_animation @base_animation
				end
			end
		end
	end
end