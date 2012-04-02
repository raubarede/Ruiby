#!/usr/bin/ruby
#####################################################################
#  sketchi.rb : edit/test component() methods
#               not an IDE....
#####################################################################
# encoding: utf-8
require_relative '../lib/ruiby'

class RubyApp < Ruiby_gtk
    def initialize
        super("Skechi",1200,0)
		@filedef=Dir.tmpdir+"/sketchi_default.rb"
		if File.exists?(@filedef)
			load(@filedef,nil)
		else
			load("new.rb",DATA.read)
		end
    end
	def component()
		stack do
			sloti(htoolbar(
				"open/Open file..."=> proc {
					load(ask_file_to_read(".","*.rb"),nil)
				},
				"Save/Save buffer to file..."=> proc {
					@file=ask_file_to_write(".","*.rb") unless File.exists?(@file)
					@title.text=@file
					content=@edit.buffer.text
					File.open(@file,"wb") { |f| f.write(content) } if @file && content && content.size>2
				}
			)) 
			stack_paned(600,0.7) {
				[flow_paned(1200,0.5) do 
					[stack {
						@title=sloti(label("Edit"))
						@edit=slot(source_editor(:lang=> "ruby", :font=> "Courier new 12")).editor
						sloti(button("Test...") { execute() })
					},
					stack { @demo=stack {label("empty...")} }
					]
				end,
				notebook do 
					page("Error") { @error_log=slot(text_area(600,100,{:font=>"Courier new 10"})) }
					page("Help") { make_help(slot(text_area(600,100,{:font=>"Courier new 10"}))) }
					page("API") { make_api(slot(text_area(600,100,{:font=>"Courier new 10"}))) }
					page("Example") { make_example(slot(text_area(600,100,{:font=>"Courier new 10"}))) }
				end
				]
			}
		end
	end
	def execute()
		@content=@edit.buffer.text
		clear_append_to(@demo) {
			frame { stack {
			eval(@content,binding() ,"<script>",1) 
			@error_log.text="ok." 
			} }
		}
		File.open(@filedef,"w") {|f| f.write(@content)} if @content.size>30
	rescue Exception => e
		trace(e)
	end
	def trace(e)
		@error_log.text="eeeee"
		@error_log.text=e.to_s + " : \n   "+ e.backtrace[0..3].join("\n   ")
	end
	def make_api(ta)
		src=File.dirname(__FILE__)+"/../lib/ruiby_gtk/ruiby_dsl.rb"
		content=File.read(src)
		ta.text=content.split(/\r?\n\s*/).grep(/^def[\s\t]+[^_]/).map {|line| line.split(/\)/)[0]+")"}.join("\n")
	end
	def make_help(ta)
		src=File.dirname(__FILE__)+"/../lib/ruiby_gtk/windows.rb"
		content=File.read(src)
		ta.text=content.split(/(=begin)|(=end)/)[2]
	end
	def make_example(ta)
		src=File.dirname(__FILE__)+"/test.rb"
		content=File.read(src)
		ta.text=content.split(/(def component)|(end # endcomponent)/)[2]
	end
	def load(file,content)
		if File.exists?(file) && content==nil
			content=File.read(file)
		end
		return unless content!=nil 
		@file=file
		@mtime=File.exists?(file) ? File.mtime(@file) : 0
		@content=content
		@edit.buffer.text=content
	end
end

Ruiby.start_secure { RubyApp.new }

__END__
stack {
	propertys("data",{int: 1,float: 1.0, array: [1,2,3], hash: {a:1, b:2}},{edit: true})  { |aa| alert aa }
	button("button 1")
	button("button 2")
	flowi {  button("button 3") ;  button("button 4")  }
	entry("",20)
	button("exit") { alert("exit? realy?") }
}

