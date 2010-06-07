#!/usr/bin/ruby
#~ Name: Jason
#~ Date last edited: 12.11.2009
require "./restclient.rb"
require "gosu"
include Gosu
module RestClient
	class Request
		attr_reader :method, :url, :payload, :headers, :user, :password, :timeout

		def self.execute(args)
			new(args).execute
		end

		def initialize(args)
			@method = args[:method] or raise ArgumentError, "must pass :method"
			@url = args[:url] or raise ArgumentError, "must pass :url"
			@headers = args[:headers] || {}
			@payload = process_payload(args[:payload])
			@user = args[:user]
			@password = args[:password]
			@timeout = args[:timeout]
		end

		def execute
			execute_inner
		rescue Redirect => e
			@url = e.url
			execute
		end

		def execute_inner
			uri = parse_url_with_auth(url)
			transmit uri, net_http_request_class(method).new(uri.request_uri, make_headers(headers)), payload
		end

		def make_headers(user_headers)
			default_headers.merge(user_headers).inject({}) do |final, (key, value)|
				final[key.to_s.gsub(/_/, '-').capitalize] = value.to_s
				final
			end
		end

		def net_http_class
			if RestClient.proxy
				proxy_uri = URI.parse(RestClient.proxy)
				Net::HTTP::Proxy(proxy_uri.host, proxy_uri.port, proxy_uri.user, proxy_uri.password)
			else
				Net::HTTP
			end
		end

		def net_http_request_class(method)
			Net::HTTP.const_get(method.to_s.capitalize)
		end

		def parse_url(url)
			url = "http://#{url}" unless url.match(/^http/)
			URI.parse(url)
		end

		def parse_url_with_auth(url)
			uri = parse_url(url)
			@user = uri.user if uri.user
			@password = uri.password if uri.password
			uri
		end

		def process_payload(p=nil, parent_key=nil)
			unless p.is_a?(Hash)
				p
			else
				@headers[:content_type] ||= 'application/x-www-form-urlencoded'
				p.keys.map do |k|
					key = parent_key ? "#{parent_key}[#{k}]" : k
					if p[k].is_a? Hash
						process_payload(p[k], key)
					else
						value = URI.escape(p[k].to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
						"#{key}=#{value}"
					end
				end.join("&")
			end
		end

		def transmit(uri, req, payload)
			setup_credentials(req)

			net = net_http_class.new(uri.host, uri.port)
			net.use_ssl = uri.is_a?(URI::HTTPS)
			net.verify_mode = OpenSSL::SSL::VERIFY_NONE

			display_log request_log

			net.start do |http|
				http.read_timeout = @timeout if @timeout
				res = http.request(req, payload)
				display_log response_log(res)
				string = process_result(res)
				if string
					Response.new(string, res)
				else
					nil
				end
			end
		rescue EOFError
			raise RestClient::ServerBrokeConnection
		rescue Timeout::Error
			raise RestClient::RequestTimeout
		end

		def setup_credentials(req)
			req.basic_auth(user, password) if user
		end

		def process_result(res)
			if %w(200 201 202).include? res.code
				decode res['content-encoding'], res.body
			elsif %w(301 302 303).include? res.code
				url = res.header['Location']

				if url !~ /^http/
					uri = URI.parse(@url)
					uri.path = "/#{url}".squeeze('/')
					url = uri.to_s
				end

				raise Redirect, url
			elsif res.code == "304"
				raise NotModified
			elsif res.code == "401"
				raise Unauthorized, res
			elsif res.code == "404"
				raise ResourceNotFound, res
			else
				raise RequestFailed, res
			end
		end

		def decode(content_encoding, body)
			if content_encoding == 'gzip'
				Zlib::GzipReader.new(StringIO.new(body)).read
			elsif content_encoding == 'deflate'
				Zlib::Inflate.new.inflate(body)
			else
				body
			end
		end

		def request_log
			out = []
			out << "RestClient.#{method} #{url.inspect}"
			out << (payload.size > 100 ? "(#{payload.size} byte payload)".inspect : payload.inspect) if payload
			out << headers.inspect.gsub(/^\{/, '').gsub(/\}$/, '') unless headers.empty?
			out.join(', ')
		end

		def response_log(res)
			"# => #{res.code} #{res.class.to_s.gsub(/^Net::HTTP/, '')} | #{(res['Content-type'] || '').gsub(/;.*$/, '')} #{(res.body) ? res.body.size : nil} bytes"
		end

		def display_log(msg)
			return unless log_to = RestClient.log

			if log_to == 'stdout'
				STDOUT.puts msg
			elsif log_to == 'stderr'
				STDERR.puts msg
			else
				File.open(log_to, 'a') { |f| f.puts msg }
			end
		end

		def default_headers
			{ :accept => 'application/xml', :accept_encoding => 'gzip, deflate' }
		end
	end
end
	class Resource
		attr_reader :url, :options

		def initialize(url, options={}, backwards_compatibility=nil)
			@url = url
			if options.class == Hash
				@options = options
			else # compatibility with previous versions
				@options = { :user => options, :password => backwards_compatibility }
			end
		end

		def get(additional_headers={})
			Request.execute(options.merge(
				:method => :get,
				:url => url,
				:headers => headers.merge(additional_headers)
			))
		end

		def post(payload, additional_headers={})
			Request.execute(options.merge(
				:method => :post,
				:url => url,
				:payload => payload,
				:headers => headers.merge(additional_headers)
			))
		end

		def put(payload, additional_headers={})
			Request.execute(options.merge(
				:method => :put,
				:url => url,
				:payload => payload,
				:headers => headers.merge(additional_headers)
			))
		end

		def delete(additional_headers={})
			Request.execute(options.merge(
				:method => :delete,
				:url => url,
				:headers => headers.merge(additional_headers)
			))
		end

		def to_s
			url
		end

		def user
			options[:user]
		end

		def password
			options[:password]
		end

		def headers
			options[:headers] || {}
		end

		def timeout
			options[:timeout]
		end

		def [](suburl)
			self.class.new(concat_urls(url, suburl), options)
		end

		def concat_urls(url, suburl)   # :nodoc:
			url = url.to_s
			suburl = suburl.to_s
			if url.slice(-1, 1) == '/' or suburl.slice(0, 1) == '/'
				url + suburl
			else
				"#{url}/#{suburl}"
			end
		end
	end

class OnlineHighScoreList
    attr_reader :resource, :high_scores
    
    def initialize(options = {})
      @limit = options[:limit] || 100
      @sort_on = options[:sort_on] || :score
      @login = options[:login] || options[:user]
      @password = options[:password]
      @game_id = options[:game_id]
 
      #~ require 'rest_client'
      require 'crack/xml'
      @resource = Resource.new("http://api.gamercv.com/games/#{@game_id}/high_scores", 
                                              :user => @login, :password => @password, :timeout => 20, :open_timeout => 5)
                                              
      @high_scores = Array.new  # Keeping a local copy in a ruby array
    end
    
    #
    # Create a new high score list and try to load content from :file-parameter
    # If no :file is given, HighScoreList tries to load from file "high_score_list.yml"
    #
    def self.load(options = {})
      high_score_list = OnlineHighScoreList.new(options)
      high_score_list.load
      return high_score_list     
    end
            
    #
    # POSTs a new high score to the remote web service
    #
    # 'data' is a hash of key/value-pairs that can contain
    # :name - player-name, could be "AAA" or "Aaron Avocado"
    # :score - the score 
    # :text - free text, up to 255 chars, 
    #
    # Returns the position the new score got in the high score list.
    # return 1 for number one spot. returns -1 if it didn't quallify as a high scores.
    #
    def add(data)
      raise "No :name value in high score!"   if data[:name].nil?
      raise "No :score value in high score!"  if data[:score].nil?
      begin
        @res = @resource.post({:high_score => data})
        data = Crack::XML.parse(@res)
        add_to_list(force_symbol_hash(data["high_score"]))
      rescue RestClient::RequestFailed
        puts "RequestFailed: couldn't add high score"
      rescue RestClient::ResourceNotFound
        return -1
      rescue RestClient::Unauthorized
        puts "Unauthorized to add high score (check :login and :password arguments)"
      end
      return data["high_score"]["position"]
    end
    alias << add
    
    #
    # Returns the position 'score' would get in among the high scores:
    #   @high_score_list.position_by_score(999999999) # most likely returns 1 for the number one spot
    #   @high_score_list.position_by_score(1)         # most likely returns nil since no placement is found (didn't make it to the high scores)
    #
    def position_by_score(score)
      position = 1
      @high_scores.each do |high_score|
        return position   if score > high_score[:score]
        position += 1
      end
      return nil
    end
    
    #
    # Load data from remove web service.
    # Under the hood, this is accomplished through a simple REST-interface
    # The returned XML-data is converted into a simple Hash (@high_scores), which is also returned from this method.
    #
    def load
      raise "You need to specify a Game_id to load a remote high score list"    unless defined?(@game_id)
      raise "You need to specify a Login to load a remote high score list"      unless defined?(@login)
      raise "You need to specify a Password to load a remote high score list"   unless defined?(@password)
      
      @high_scores.clear
      begin
        res = @resource.get
        data = Crack::XML.parse(res)
        if data["high_scores"]
          data["high_scores"].each do |high_score|
            @high_scores.push(force_symbol_hash(high_score))
          end
        end
      rescue RestClient::ResourceNotFound
        puts "Couldn't find Resource, did you specify a correct :game_id ?"
      end
      
      @high_scores = @high_scores[0..@limit-1] unless @high_scores.empty?
      return @high_scores
    end
    
    #
    # Direct access to @high_scores-array
    #
    def [](index)
      @high_scores[index]
    end
    
    #
    # Iterate through @high_scores-array with each
    #
    def each
      @high_scores.each { |high_score| yield high_score }
    end
 
    #
    # Iterate through @high_scores-array with each_with_index
    #
    def each_with_index
      @high_scores.each_with_index { |high_score, index| yield high_score, index }
    end
    
    private
    
    def add_to_list(data)
      @high_scores.push(data)
      @high_scores.sort! { |a, b| b[@sort_on] <=> a[@sort_on] }
      @high_scores = @high_scores[0..@limit-1]
    end
    
    def force_symbol_hash(hash)
      symbol_hash = {}
      hash.each_pair do |key, value|
        symbol_hash[key.to_sym] = value
      end
      return symbol_hash
    end
        
end

@high_score_list = OnlineHighScoreList.new(:game_id => 10, :login => "ETERNITY", :password => "GateOfMana", :limit => 10)
#~ puts @high_score_list.inspect
data = {:name => "NEW", :score => 0001, :text => "Hello world"}
    position = @high_score_list.add(data)
    puts "Got position: #{position.to_s}"
    create_text