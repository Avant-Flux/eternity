#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 12.11.2009

require 'rubygems'
require 'open-uri'
require 'crack'

require 'net/http'
require 'uri'

## Fetch the data, make sure we get XML by setting the Accept-header
content = open("http://gamercv.com/games/1/high_scores", {"Accept" => "application/xml"}).read

## Convert XML into a standard Ruby array and print it
#~ puts content
output = Crack::XML.parse(content)


output["high_scores"].each do |x|
	puts "Created at: " + x["created_at"].to_s + "\n"
	puts "	Game ID: " + x["game_id"].to_s + "\n"
	puts "	Name: " + x["name"].to_s + "\n"
	puts "	Position: " + x["position"].to_s + "\n"
	puts "	Score: " + x["score"].to_s + "\n"
	puts "	Text: " + x["text"].to_s + "\n"
	puts "	Updated At: " + x["updated_at"].to_s + "\n"
	puts "	User ID: " + x["user_id"].to_s + "\n"
end