
	# Sputnik - Style Prototyping Utility for Mapnik
	# Richard Fairhurst 2014/2018. WTFPL.

	require 'webrick'
	require 'simple_mapnik'
	require 'securerandom'
	require 'spherical_mercator'

	SimpleMapnik.register_datasources `mapnik-config --input-plugins`.chomp
	SimpleMapnik.register_fonts `mapnik-config --fonts`.chomp
	$mercator = SphericalMercator.new(size: 256)

	class MapTile < WEBrick::HTTPServlet::AbstractServlet
		def do_GET(request, response)
			_,_,z,x,y=request.path.split('/')
			bbox_ll = $mercator.bbox(x.to_i, y.to_i, z.to_i)
			bbox_sm = $mercator.convert(bbox_ll, '900913')

			response.status = 200
			response['Content-Type']  = 'image/png'
			response['Cache-Control'] = 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0'
			response['Pragma']        = 'no-cache'
			$style.map.zoom_to(SimpleMapnik::Bounds.new(*bbox_sm))
			fn = "/tmp/#{SecureRandom.uuid}.png"
			$style.map.to_file(fn)
			if $style.map.last_error then puts $style.map.last_error end
			response.body = File.read(fn)
			File.delete(fn)
		end

		def zoom_x_y_to_lat_lng(zoom, x, y)
			n = 2.0 ** zoom
			lon_deg = x / n * 360.0 - 180.0
			lat_rad = Math.atan(Math.sinh(Math::PI * (1 - 2 * y / n)))
			lat_deg = lat_rad * 180.0 / Math::PI
			[lon_deg, lat_deg]
		end
	end

	module SimpleMapnik
	  class Map
	    def last_error
	      mapnik_map_last_error @ptr
	    end
	  end
	end

	class Stylesheet
		attr_reader :xml, :map
		def initialize(mml)
			@mml = mml
			@styledir = File.dirname(mml)
			refresh
		end
		def refresh
			xml = `carto -n #{@mml}`
			postprocessed = xml.lines.map do |line|
				if line=~ /^(.*<!\[CDATA\[.+?)(<Placement.+)\]\]>(.+)$/ then
					pre=$1; exp=$2; post=$3
					"#{$1}]]>#{$2}#{$3}"
				else line end
			end
			Dir.chdir(@styledir) do
				File.write(".tmp.xml",postprocessed.join)
				@map = SimpleMapnik::Map.new(256,256)
				@map.load(".tmp.xml")
				if (e = map.last_error) then puts e end
			end
		end
	end

	# Start server

	$style = Stylesheet.new(ARGV[0])
	server = WEBrick::HTTPServer.new(:Port => 8000, :AccessLog => [], :Logger => WEBrick::Log::new("/dev/null", 7))
	server.mount "/tile", MapTile
	server.mount_proc "/refresh" do |request,response|
		$style.refresh
		response.status=200; response['Content-Type']='application/javascript'; response.body="refresh();"
	end
	server.mount_proc "/" do |request,response|
		response.status=200; response['Content-Type']='text/html'; response.body=File.read('sputnik.html')
	end
	trap "INT" do server.shutdown end
	puts "Sputnik launched"
	server.start
