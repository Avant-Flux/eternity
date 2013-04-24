module Component
	class Equipment
		DEFAULT_OPTIONS = {
			:head => nil,
			
			:body => nil,
			:legs => nil,
			:feet => nil,
			:hands => nil,
			
			:weapon_right => nil,
			:weapon_left => nil
		}
		
		def initialize(window, physics, base_model, base_animation, opts)
			opts = DEFAULT_OPTIONS.merge opts
			
			@physics = physics
			@base_model = base_model
			@base_animation = base_animation
			
			@models = Hash.new
			@animations = Hash.new
			
			@weapon_models = Hash.new
			
			
			# Configure weapons
			[:weapon_right].each do |weapon|
				mesh_name = opts[weapon]
				model = Component::Model.new window, mesh_name
				
				if :weapon_right
					@base_model.attach_object_to_bone "hand.R", model
				else # :weapon_left
					@base_model.attach_object_to_bone "hand.L", model
				end
				
				model.position = [0,0,0]
				model.rotation = 0
				
				opts.delete weapon
				
				@weapon_models[mesh_name] = model
			end
			
			# Configure everything else
			opts.each do |equipment_type, mesh_name|
				next unless mesh_name
				
				@models[equipment_type] = Component::Model.new(window, mesh_name)
				
				@animations[equipment_type] = Oni::Animation.new @models[equipment_type]
			end
		end
		
		def update(dt)
			@models.each_value do |m|
				m.update dt
				
				# Copied from Component::Collider::Base in Compnents/Physics.rb
				m.position = [@physics.body.p.x, @physics.body.pz, -@physics.body.p.y]
				m.rotation = @physics.body.a + Math::PI/2
			end
			
			@animations.each_value do |a|
				# Set the equipment model to match the animation for the body
				a.animations.each do |animation_name|
					if @base_animation[animation_name].enabled?
						a[animation_name].enable
						
						# Copy state from base
						a[animation_name].weight = @base_animation[animation_name].weight
						a[animation_name].time = @base_animation[animation_name].time
						a[animation_name].loop = @base_animation[animation_name].loop
						a[animation_name].rate = @base_animation[animation_name].rate
					else
						a[animation_name].disable
					end
				end
			end
		end
	end
end