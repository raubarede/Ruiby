# Creative Commons BY-SA :  Regis d'Aubarede <regis.aubarede@gmail.com>
# LGPL

################################################################################
# select * from netstat join tasklist where *.to_s like '%1%'    ;)
################################################################################
raise("not windows!") unless RUBY_PLATFORM =~ /in.*32/
require 'gtk3'
require_relative '../lib/Ruiby'

$fi=ARGV[0] || "LISTENING"
$filtre=Regexp.new($fi)

class Ruiby_gtk
	def make_list_process()
		hpid={}
		%x{tasklist}.split(/\r?\n/).each { |line| 
		  ll=line.chomp.split(/\s+/) 
		  next if ll.length<5
		  prog,pid,_,_,*l=ll
		  hpid[pid]= [prog,l.join(" ")]
		}
		hpid
	end
	def net_to_table(filtre)
		hpid=make_list_process()
		ret=[]
		%x{netstat -ano}.split(/^/).each { |line|
		 _,src,dst,flag,pid=line.chomp.strip.split(/\s+/)  
		 prog,s = hpid[pid]||["?","?"]
		 ret << [flag,src,dst,prog,pid.to_i,s] if [flag,src,dst,prog,pid,s].inspect =~  filtre	 
		}
		ret.sort { |a,b| a[4]<=>b[4]}
	end
end

Ruiby.app(:width => 0, :height => 0, :title => "NetProg #{$fi}") do
	@periode=2000
	stack do
		@grid=grid(%w{flag source destination proc pid proc-size},500,100)
		@grid.set_data(net_to_table($filtre))	
		buttoni("Refresh") { @grid.set_data(net_to_table($filtre)) }
		flowi do
			button("Filter") { prompt("Filter ?",$fi) { |value| $fi=value;$filtre=Regexp.new($fi) } }
			button("Periode") { 
				prompt("periode (ms) ?",@periode.to_s) { |value| 
					delete(@ann)
					@periode=[1000,20000,value.to_i].sort[1]
					@ann=anim(@periode) { 
						Thread.new {
							d=net_to_table($filtre) ; gui_invoke { @grid.set_data(d) } 
						} unless @active.active? 
					} 
				}
			}
			@active=check_button("Freese",false) 
		end
	end
	@ann=anim(@periode) { 
		Thread.new {
			d=net_to_table($filtre) ; gui_invoke { @grid.set_data(d) } 
		} unless @active.active? 
	} 
end
