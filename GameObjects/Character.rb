  1 #!/usr/bin/ruby
  2 
  3 require './Chipmunk/Space_3D'
  4 require "./Titles/Title_Holder"
  5 require "./GameObjects/Entity"
  6 #To be used for NPCs, such as enemy units
  7 #Townspeople (ie shopkeeper etc) should be under a different class
  8 class Character < Entity
  9 	attr_accessor :charge, :str, :con
 10 	attr_accessor :inventory, :equipment
 11 	
 12 	def initialize(space, name, pos = [0, 0, 0], 
 13 					subsprites={:body => 1, :face => 1, :hair => 1, 
 14 								:upper => "shirt1", :lower => "pants1", :footwear => "shoes1"},
 15 					mass=120, moment=20)
 16 					
 17 		animation = Animations::Character.new subsprites
 18 		super(space, animation, name, pos, mass, moment, 1, :none, 
 19 				{:str => 10, :con => 10, :dex => 10, :agi => 10, :luk => 10,
 20 				:pwr => 10, :ctl => 10, :per => 10}, 0)
 21 
 22 		#Remember to set atk and def based on str and con as well as other factors
 23 		
 24 		@charge = 0			#0 is normal, 1 is fired-up, -1 is suppressed
 25 		@inventory = {:consumable => [], :equipable => [], :key_items => []}
 26 		@equipment =	{:head => nil, :right_hand => nil, :left_hand => nil, 
 27 						:upper_body => nil, :lower_body => nil, :feet => nil, 
 28 						:title => Title_Holder.new}
 29 	end
 30 	
 31 	def lvl=(arg)
 32 		@lvl = arg
 33 		
 34 		set_stats
 35 		
 36 		@hp[:current] = @hp[:max]
 37 		@mp[:current] = @mp[:max]
 38 	end
 39 	
 40 	def use_item
 41 		
 42 	end
 43 	
 44 	def say text
 45 		
 46 		# Create new point class
 47 		point = Struct.new(:x,:y)
 48 		
 49 		# Store each point of the text box in an ordered pair (x,y)
 50 		point1 = point.new x.to_px - 60, y.to_px - height - 100
 51 		point2 = point.new x.to_px + 60, y.to_px - height - 100
 52 		point3 = point.new x.to_px - 60, y.to_px - height - 30
 53 		point4 = point.new x.to_px + 60, y.to_px - height - 30
 54 		
 55 		# Define color for text box
 56 		color = Gosu::Color::RED
 57 		
 58 		z_offset = 1000
 59 		
 60 		# Draw box to hold character text
 72 
 73 		$window.draw_quad(point1.x, point1.y, color, 
 74 						   point2.x, point2.y, color, 
 75 						   point3.x, point3.y, color, 
 76 						   point4.x, point4.y, color, z+z_offset)
 77 		
 78 		# Draw triangle that points to character that is speaking
 79 		$window.draw_triangle x.to_px - 60, y.to_px - height - 30, color, 
 80 							  x.to_px - 30, y.to_px - height - 30, color, 
 81 							  x.to_px, y.to_px - height, color, z+z_offset
 82 
 83
 84 		# Draw text in text box
 85 		@font = Gosu::Font.new $window, "Times New Roman", 25 unless @font
 86 		@font.draw text, point1.x + 1, point1.y + 1, z.to_px + 5 +z_offset
 87 	end
 88 	
 89 	private
 90 	
 91 	def set_atk
 92 		@atk = @str + @equipment[:right_hand].atk + @equipment[:left_hand].atk
 93 	end
 94 	
 95 	def set_def
 96 		@def = @con + @equipment[:right_hand].def + @equipment[:left_hand].def + 
 97 				@equipment[:head].def + @equipment[:upper_body].def + @equipment[:lower_body].def +
 98 				@equipment[:feet].def
 99 	end
100 	
101 	def set_stats
102 		if @lvl > 10
103 			compute_hp
104 			compute_mp
105 			compute_str
106 			compute_con
107 			compute_dex
108 			compute_agi
109 			compute_mnd
110 			compute_per
111 			compute_luk
112 		else
113 			stats_to_10
114 		end
115 	end
116 	
117 	def stats_to_10
118 		@hp[:max] = @mp[:max] = @str = @con = @dex = @agi = @mnd = @per = @luk = 
119 			if @lvl < 10
120 				@lvl+9
121 			else
122 				20
123 			end
124 	end
125 	
126 	def compute_hp
127 		@hp[:max] = energy case @element
128 							when :fire
129 								4
130 							when :water
131 								3
132 							when :lightning
133 								2
134 							when :wind
135 								1
136 							when :earth
137 								5
138 						end
139 	end
140 	
141 	def compute_mp
142 		@mp[:max] = energy case @element
143 							when :fire
144 								2
145 							when :water
146 								5
147 							when :lightning
148 								1
149 							when :wind
150 								4
151 							when :earth
152 								3
153 						end
154 	end
155 	
156 	def compute_str
157 		@str = rate case @element
158 						when :fire
159 							7
160 						when :water
161 							2
162 						when :lightning
163 							6
164 						when :wind
165 							1
166 						when :earth
167 							5
168 					end
169 	end
170 	
171 	def compute_con
172 		@con = rate case @element
173 						when :fire
174 							4
175 						when :water
176 							1
177 						when :lightning
178 							2
179 						when :wind
180 							3
181 						when :earth
182 							7
183 					end
184 	end
185 	
186 	def compute_dex
187 		@dex = rate case @element
188 						when :fire
189 							2
190 						when :water
191 							5
192 						when :lightning
193 							1
194 						when :wind
195 							6
196 						when :earth
197 							4
198 					end
199 	end
200 	
201 	def compute_agi
202 		@agi = rate case @element
203 						when :fire
204 							3
205 						when :water
206 							4
207 						when :lightning
208 							5
209 						when :wind
210 							7
211 						when :earth
212 							2
213 					end
214 	end
215 	
216 	def compute_mnd
217 		@mnd = rate case @element
218 						when :fire
219 							5
220 						when :water
221 							6
222 						when :lightning
223 							4
224 						when :wind
225 							2
226 						when :earth
227 							3
228 					end
229 	end
230 	
231 	def compute_per
232 		@per = rate case @element
233 						when :fire
234 							1
235 						when :water
236 							7
237 						when :lightning
238 							3
239 						when :wind
240 							5
241 						when :earth
242 							6
243 					end
244 	end
245 	
246 	def compute_luk
247 		@luk = rate case @element
248 						when :fire
249 							6
250 						when :water
251 							3
252 						when :lightning
253 							7
254 						when :wind
255 							4
256 						when :earth
257 							1
258 					end
259 	end
260 	
261 	def rate arg
262 		case arg
263 			when 7
264 				((43/9.0)*@lvl-(250/9.0)).floor
265 			when 6
266 				((38/9.0)*@lvl-(200/9.0)).floor
267 			when 5
268 				((10/3.0)*@lvl-(40/3.0)).floor
269 			when 4
270 				((20/9.0)*@lvl-(20/9.0)).floor
271 			when 3
272 				((16/9.0)*@lvl+(20/9.0)).floor
273 			when 2
274 				((4/3.0)*@lvl+(20/3.0)).ceil
275 			when 1
276 				((8/9.0)*@lvl+(100/9.0)).floor
277 		end
278 	end
279 	
280 	def energy arg
281 		case arg
282 			when 5
283 				((((28.0)/(9.0))*(@lvl-10))+20).floor
284 			when 4
285 				((((266.0)/(3.0))*(@lvl-10))+20).floor
286 			when 3
287 				((((166.0)/(3.0))*(@lvl-10))+20).floor
288 			when 2
289 				(22*@lvl-200).floor
290 			when 1
291 				((((88.0)/(9.0))*(@lvl-10))+20).floor
292 		end
293 	end
294 	
295 end
