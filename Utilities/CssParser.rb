
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
		
		css.gsub! COMMENT_REGEX, ""
		css.gsub! WHITESPACE_REGEX, ""
		
		# Parse CSS rules
		css.split("}").each do |rule|
			# The "{" has been left in, delineates the end of selectors, and start of actual styles
			selectors, styles = rule.split "{"
			
			
			styles.split(";").each do |style|
				property, value = style.split ":"
			end
			
			
			selectors.split(",").each do |selector|
				
			end
		end
	end
end
