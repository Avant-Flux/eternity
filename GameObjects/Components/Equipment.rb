module Component
	class Equipment
		DEFAULT_OPTIONS = {
			:body => nil,
			:legs => nil,
			:feet => nil
		}
		
		def initialize(window, physics, base_animation, opts)
			opts = DEFAULT_OPTIONS.merge opts
			
			@physics = physics
			@base_animation = base_animation
			
			@models = Hash.new
			@animations = Hash.new
			opts.each do |equipment_type, mesh_name|
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