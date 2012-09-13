####################################################################################
#   tilesviewer.rb : show Map type OSM raster tiles 
####################################################################################
# Usage : 
#    > ruby tilesviewer.rb dir_tiles_path zoom_exam zoom_show
# Example :
#  ruby tilesviewer.rb d:\tbf_2012\saiaEclairagePublic\www\webapps\default\tiles 18 15
#    this show zomm level 18, with utilization of tiles raster of zoom level 15
#
####################################################################################
require_relative '../lib/ruiby'

if ARGV.size<3
	Message.alert("Usage\n>ruby #{$0}.rb  pathToTiles zoomLevel-examine  zommLevel-show")
	exit(0)
end


Ruiby.app(:width=> 800, :height=>800, :title=> "Tiles on #{ARGV[0]}") do
	dir="#{ARGV[0]}/#{ARGV[1]}".gsub('\\','/')
	
	z=ARGV[1].to_i
	za=ARGV[2].to_i
	sa=z-1 			if za<= z	
	diz="#{ARGV[0]}/#{za}".gsub('\\','/').gsub('\\','/')
	
	diff=2**(z-za) # nb tiles in level z for one tile in za level; by axe
	
	raise ("tiles dir not exist !") unless File.exists?(dir);
	raise ("tiles dir not exist !") unless File.exists?(diz);
	
	puts "scan dir X..."
	ld=Dir.entries(dir+"/").select {|n| n =~ /^\d+$/}.map {|d| d.to_i}.sort
	tab=Hash.new { |h,k| h[k]=Hash.new  }
	thy={}
	puts "scan dir Y..."
	ld.each { |y|
		ydir="#{dir}/#{y}"
		xld=Dir.entries(ydir).select {|n| n =~ /^\d+.png$/}.map {|d| d.split('.').first.to_i}.sort
		xld.each.each { |x|  
		  tab[x][y]="#{dir}/#{y}/#{x}.png" 
		  thy[y]=1
		}
	}
	puts "go tiles draw..."
	minx,maxx= tab.keys.minmax
	miny,maxy= thy.keys.minmax
	vbox_scrolled(800,800) do 
		center {frame { table((maxx-minx),(maxy-miny)) do
			(minx..maxx).each { |x|
				next if (x % diff)!=0
				p x
				row { 
					if tab[x].size>0
				      (miny..maxy).each { |y|  
						next if (y % diff)!=0
						filename="#{diz}/#{y/diff}/#{x/diff}.png"
					    cell( File.exists?(filename) ? image( filename,{:size=>24})  : label("") ) 
				      }
					else
					   cell(label(" "))
					end
				}
			 }
		end } }
	end
end