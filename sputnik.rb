
	# Sputnik - Style Prototyping Utility for Mapnik
	# Richard Fairhurst 2014. WTFPL.
	
	require 'webrick'
	require 'mapnik'

	class MapTile < WEBrick::HTTPServlet::AbstractServlet
		def do_GET(request, response)
			_,_,z,x,y=request.path.split('/')
			tile = Mapnik::Tile.new(z.to_i, x.to_i, y.to_i)
			response.status = 200
			response['Content-Type']  = 'image/png'
			response['Cache-Control'] = 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0'
			response['Pragma']        = 'no-cache'
			response.body = tile.render_to_string($style.map)
		end
	end

	class Stylesheet
		attr_reader :xml, :map
		def initialize(mml,styledir)
			@mml = mml
			@styledir = styledir
			refresh
		end
		def refresh
			xml = `carto -n #{@mml}`
			postprocessed = xml.lines.map do |line|
				if line=~ /^(.+<!\[CDATA\[.+?)(<Placement.+)\]\]>(.+)$/ then
					pre=$1; exp=$2; post=$3
					"#{$1}]]>#{$2}#{$3}"
				else line end
			end
			@map = Mapnik::Map.from_xml(postprocessed.join, false, @styledir)
		end
	end

	# Start server

	$style = Stylesheet.new(ARGV[0], ARGV[1])
	server = WEBrick::HTTPServer.new(:Port => 8000, :AccessLog => [], :Logger => WEBrick::Log::new("/dev/null", 7))
	server.mount "/tile", MapTile
	server.mount_proc "/refresh" do |request,response|
		$style.refresh
		response.status=200; response['Content-Type']='application/javascript'; response.body="refresh();"
	end
	trap "INT" do server.shutdown end
	puts "Sputnik launched"
	server.start
