require_relative 'rspec_helper.rb'

describe Ruiby do
 before(:each) do
	@win= make_window
 end
 after(:each) do
	destroy_window(@win)
 end
  it "create a table" do
		w=nil
		@win.create { stack {   w=table(0,0) { 
			row { cell(button("ee")) ; cell(button("ee"))}
			row { cell(button("ee")) ; cell(button("ee"))}
		} } }
		@win.sleeping(100,"Verify canvas")
		 w.should be_a_kind_of(Gtk::Table)
 end
  it "create a table with  cell h/v span" do
		w=nil
		@win.create { stack {   w=table(0,0) { 
			row { cell_hspan(2,button("EE")) ; cell(button("ee"))}
			row { cell(button("ee")) ; cell(button("ee")); cell(button("ee"))}
			row { cell(button("ee")) ; cell_hspan(2,button("AA"))}
			row { cell_vspan(2,button("HH")) ; cell(button("ee")); cell(button("ee"))}
			row { cell_pass() ; cell(button("ee")); cell(button("ee"))}
		} } }
		@win.sleeping(100)
		 w.should be_a_kind_of(Gtk::Table)
 end
  it "create a table with  cell alignement" do
		w=nil
		@win.create { stack {   w=table(0,0) { 
			row { cell_right(button("To Right")) ; cell(button("eeeeee"))}
			row { cell(button("dddddddddee")) ; cell_left(button("To Left"));}
			row { cell_bottom(button("To bottom")) ; cell_top(button("To Lop"));}
		} } }
		@win.sleeping(100)
		w.should be_a_kind_of(Gtk::Table)
 end
  it "create a table with  cell alignement" do
		w=nil
		@win.create { stack {   w=table(0,0) { 
			row { cell_right(button("To Right")) ; cell(button("eeeeee"))}
			row { cell(button("dddddddddee")) ; cell_left(button("To Left"));}
			row { cell_bottom(button("To bottom")) ; cell_top(button("To Lop"));}
		} } }
		@win.sleeping(100)
		w.should be_a_kind_of(Gtk::Table)
 end
 
  it "create properties shower" do
		w=nil
		data={a: 2, b: 4, c: 6}
		@win.create { stack {   
			w=properties("Title",data)
		} } 
		@win.sleeping(100)
		w.should be_a_kind_of(Gtk::VBox)
		t=w.children.first.children.first.children.first.children.first
		t.should be_a_kind_of(Gtk::Table)
 end
  it "create properties editor" do
		w=nil
		data={a: 2, b: 4, c: 6}
		@win.create { stack {   
			w=properties("Title",data,edit: true)
		} } 
		@win.sleeping(100)
		w.should be_a_kind_of(Gtk::VBox)
		t=w.children.first.children.first.children.first
		t.children.first.should be_a_kind_of(Gtk::Table)
		t.children.size.should eq(2)
 end
  it "set/get data in properties editor" do
		w=nil
		data={a: 2, b: 4, c: 6}
		@win.create { stack {   
			w=properties("Title",data,edit: true)
		} } 
		@win.sleeping(100)
		t=w.children.first.children.first.children.first.children.first
		t.should be_a_kind_of(Gtk::Table)
		w.get_data.should be_a_kind_of(Hash)
		w.get_data[:a].should eq(2)
		10.times { |c|
			w.set_data({a: c, b: c*c, c: c*c*c})
			Ruiby.update
			w.get_data[:a].should eq(c)
			w.get_data[:b].should eq(c*c)
			w.get_data[:c].should eq(c*c*c)
		}
 end
  it "create a notebook" do
		w=nil
		@win.create { stack {   w=notebook() { 
			page("eeee1") { label('page 1') }
			page("eeee2") { label('page 2')}
			page("eeee3") { label('page 3')}
			page("aa","#open") { label('page 4')}
		} } }
		@win.sleeping(100,"Verify notebook")
		w.should be_a_kind_of(Gtk::Notebook)
 end
  it "create a menu" do
		w=nil
		@win.create { stacki {   
		   w=menu_bar {
			menu("F") {
				menu_button("a") { } ; 
				menu_separator; 
				menu_checkbutton("b") { |w|} 
			}
		} } }
		@win.sleeping(100,"Verify canvas")
		w.should be_a_kind_of(Gtk::MenuBar)
 end
  it "create a accordion" do
		w=nil
		@win.create { stack {
		   w=accordion {
				aitem("aaa") { alabel("eee") ;  alabel("eee") ; alabel("eee") ;}
				aitem("bbb") { l=alabel("alert...") { alert("ok") }}
				aitem("ccc") { alabel("eee")}
		   }
		} }
		@win.sleeping(100,"Verify accordion")
		w.should be_a_kind_of(Gtk::VBox)
 end
  it "create panneds" do
		w=nil
		@win.create { stack {
		   w=stack_paned(100,0.5) {
		     [
			 flow_paned(100,0.7) { [ box { button("ee") }, box {button("ee") } ]},
			 flow_paned(200,0.3) { [ box { button("ee") }, box {button("ee") } ]}
			 ]
		   }
		} }
		@win.sleeping(100,"Verify panned")
		w.should be_a_kind_of(Gtk::VPaned)
 end
  it "create calendar" do
		w=[]
		@win.create { flow {
		   w << calendar()
		   w << calendar()
		   w << calendar()
		} }
		@win.sleeping(100,"Verify panned")
		w[0].should be_a_kind_of(Gtk::Calendar)
		w[0].set_time(Time.local(2000,10,10))
		w[0].get_time().should eq(Time.local(2000,10,10))
 end
 it "create scrolled box" do
		w=nil
		@win.create { stack {
		   w=scrolled(100,100) {
				stack { 50.times { |r| flow { 10.times { |c| button("#{r} #{c} dddde") } } } }
		   }
		   w2=vbox_scrolled(100,100) {
				stack { 50.times { button("aaa")} }
		   }
		} }
		@win.sleeping(10,"Verify scolled")
		w.should be_a_kind_of(Gtk::ScrolledWindow) 
		w.scroll_to_top		;@win.sleeping(300)
		w.scroll_to_bottom	;@win.sleeping(300)
		#w.scroll_to_right	;@win.sleeping(1000,"Verify scolled") bug!!
		#w.scroll_to_left	;@win.sleeping(1000,"Verify scolled") bug!!
 end
 it "create clickable" do
		w=nil
		@win.create { stack {
		   pclickable(proc { alert("clicked") }) { w=label(" please clik me ") }
		} }
		@win.sleeping(100,"Verify scolled")
		w.should be_a_kind_of(Gtk::Label) 
 end
end