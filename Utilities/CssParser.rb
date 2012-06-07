
class CssParser
	WHITESPACE_REGEX = /\s+/
	COMMENT_REGEX = /\/\*.*?\*\//m
	
	def initialize
		@elements = {
			:div => {
				:color => "green"
			}
		}
		@ids = {
			:main => {
				:color => "red"
			}
		}
		@classes = {
			:test_class = {
				:color => "blue"
			}
		}
	end
	
	
	def select(selection)
		# Psuedo-selectors
		# :active, :hover, :focus, :first-letter, :first-line, :first-child
		
		selection.gsub! COMMENT_REGEX, ""
		selection.gsub! WHITESPACE_REGEX, ""
		
		
	end
	
	# Load additional stylesheet from file
	def load(path_to_file)
		css = ""
		File.open(path_to_file, "r").each do |line|
			css += line
		end
		
		# Strip out extraneous bits
		css.gsub! COMMENT_REGEX, ""
		css.gsub! WHITESPACE_REGEX, ""
		
		# Parse CSS rules
		css.split("}").each do |rule|
			# The "{" has been left in, delineates the end of selectors, and start of actual styles
			selectors, styles = rule.split "{"
			
			
			style_hash = parse_styles styles
			
			
			selectors.split(",").each do |selector|
				
			end
		end
	end
	
	private
	
	# Replace dashes with underscores, and convert to a symbol
	def parse_property(property_string)
		return property_string.split("-").join("_").to_sym
	end
	
	# Convert value from string into proper type
	def parse_value(property, value_string)
		if property == :color
			if value_string[0] == "#"
				# HEX code
			else
				begin
					return Gosu::Color.const_get value_string
				rescue
					# Not one of the default colors, begin to parse color format
					# argb, ahsv, hsv, rgba
					
					# 
					value_string
				end
			end
		elsif
			
		end
		
		return nil
	end
	
	# Convert the styles under the current selector(s) into a hash
	def parse_styles(style_string)
		# Store all the styles defined under this statement
		style_hash = Hash.new
		
		style_string.split(";").each do |style|
			property, value = style.split ":"
			
			property = parse_property property
			value = parse_value property, value
			
			style_hash[property] = value
		end
		
		return style_hash
	end
end
