# Creative Commons BY-SA :  Regis d'Aubarede <regis.aubarede@gmail.com>
# LGPL
require_relative 'rspec_helper.rb'

describe Ruiby do
 before(:each) do
  @win= make_window
 end
 after(:each) do
  destroy_window(@win)
 end
 it "window primitive : rposition" do
   @win.rposition(0,0)
   @win.rposition(11,0)
   @win.rposition(0,11)
   @win.rposition(11,11)
   @win.rposition(-11,0)
   @win.rposition(0,-11)
   @win.rposition(-11,-11)
 end
 it "window primitive : chrome" do
   @win.chrome(false)
   @win.sleeping(100)
   @win.chrome(true)
   @win.sleeping(100)
 end
 it "create a button" do
    s=nil;@win.create { s=stack {  } }
    @win.append_to(s) { @win.button("CouCou") { puts "coucou" } }
    s.children.size.should eq(1)
 end
 it "create a label" do
    s=nil;@win.create { s=stack {  } }
    @win.append_to(s) { @win.label("CouCou")  }
    s.children.size.should eq(1)
 end
 it "create a label with icon" do
    s=nil;@win.create { s=stack {  } }
    @win.append_to(s) { @win.label("#open")  }
    @win.sleeping(100,"Verify slot/sloty")
    s.children.size.should eq(1)
 end
 it "create a labeli and buttoni, checking min/auto size" do
    s=nil;@win.create { 
      label "without slotti"
      s=flow {  
        button("i")
        label("i")
        button("openssssssssssssssss")		
        button("#open")		
      }
      label "with slotti on 'i' widget"
      s=flow {  
        buttoni("i")
        labeli("i")
        button("openssssssssssssssss")		
        buttoni("#open")		
      }
    }
    @win.sleeping(100,"Verify slot/sloty")
    s.children.size.should eq(4)
 end
 it "create a label with file image" do
    w=[];
    @win.create { stack {  
      label("file reaster is :")
      w << label("##{$here}/draw.png")  
      label("sub part of the raster file :")
      w << label("##{$here}/draw.png[0,0]x22")  
      w << label("##{$here}/draw.png[1,0]x22")  
      w << label("##{$here}/draw.png[2,0]x22")  
      w << label("##{$here}/draw.png[1,1]x22")  
      w << label("##{$here}/draw.png[2,1]x22")  
    } } 
    @win.sleeping(100,"Verify images")
    w.each { |x| x.should be_a_kind_of(Gtk::Image) }
    w.each { |x| x.pixbuf.should be_a_kind_of Gdk::Pixbuf}
    w[1..-1].each { |x| x.pixbuf.width.should eq(22)}
    
 end
 it "create a image with scale " do
    w=[];
    @win.create { stack {  
      w << image("#{$here}/draw.png",{width: 100, height: 200})  
      w << image("#{$here}/draw.png",{size: 200})  
    } } 
    @win.sleeping(100,"Verify images")
    w.each { |x| x.should be_a_kind_of(Gtk::Image) }
    w.each { |x| x.pixbuf.should be_a_kind_of Gdk::Pixbuf}		
 end
 it "create a entry" do
    w=nil
    @win.create { stack {   w=entry("CouCou") { alert("key pressed ok") } } }
    @win.sleeping(100,"Verify entry")
     w.should be_a_kind_of(Gtk::Entry)
 end
 it "create a ientry" do
    w=nil
    @win.create { stack {   w=ientry(22,min: 0, max: 100,by: 1) { alert("value modify, ok") } } }
    @win.sleeping(100,"Verify fentry")
     w.should be_a_kind_of(Gtk::SpinButton)
 end
 it "create a fentry" do
    w=nil
    @win.create { stack {   w=fentry(22,min: 0, max: 10,by: 0.1) { alert("value modify, ok") } } }
    @win.sleeping(100,"Verify fentry")
    w.should be_a_kind_of(Gtk::SpinButton)
 end
  it "create a image from file" do
    w=nil
    filename="../samples/media/angel.png"
    filename="samples/media/angel.png" unless File.exists?(filename)
    @win.create { stack {   w=image(filename) } }
    w.should be_a_kind_of(Gtk::Image)
 end

 it "create fields" do
    w=nil
    @win.create { stack {   w=fields("aa"=>0,"bb"=>1)  } }
    @win.sleeping(100,"Verify fields")
    w.should be_a_kind_of(Gtk::Box)
    w.children.size.should eq(2)
 end
 it "create  fields with validation" do
    w=nil
    @win.create { stack {   w=fields("aa"=>0,"bb"=>1) { alert("value modify, ok") } } }
    @win.sleeping(100,"Verify fields")
    w.should be_a_kind_of(Gtk::Box)
    w.children.size.should eq(3)
 end
 it "create a slider" do
    w=nil
    @win.create { stack {   w=islider(22,min: 0, max: 100,by: 1) { |v|p v} } }
    @win.sleeping(100,"Verify islider")
    w.should be_a_kind_of(Gtk::Scale)
 end
 it "create a combo box" do
    w=nil
    @win.create { stack {    
      w=combo("a"=> 1,"b"=>2)
    } }
    w.should be_a_kind_of(Gtk::ComboBox)
 end
 it "create radio buttons" do
    w=nil
    @win.create { stack {    
       w=hradio_buttons(%w{a b c d e f},2)
       vradio_buttons(%w{a b c d e f},2)
    } }
    w.children[0].should be_a_kind_of(Gtk::RadioButton)
 end
 it "create toggle button" do
    w=nil
    @win.create { stack {    
      w=toggle_button("on","off",false) { }
    } }
    w.should be_a_kind_of(Gtk::ToggleButton)
 end
 it "create check button" do
    w=nil
    @win.create { stack {    
      w=check_button("check button 1",false) 
      w=check_button("check button 2",true) 
    } }
    w.should be_a_kind_of(Gtk::CheckButton)
 end
 it "create color choice button" do
    w=nil
    @win.create { stack {    
      w=color_choice("texte") { } 
    } }
    w.should be_a_kind_of(Gtk::Box)
 end
 it "create text area" do
    w=nil
    @win.create { stack {    
      w=text_area(100,100,{:text=> "ddd",:font=>"Courier 10"})
    } }
    w.children[0].should be_a_kind_of(Gtk::TextView)
    content=%w{a b c d e f}.join("\n")
    w.text=content
    w.text.size.should eq(content.size)
 end
 it "create a Dyn slider" do
    v=DynVar.new(22)
    @win.create {   w=islider(v,min: 0, max: 100,by: 1) } 
    v.value=33.0
    v.value=44.0
    v.value.should eq(44.0)
 end
 it "create a Dyn ientry" do
    v=DynVar.new(22)
    @win.create {   w=ientry(v) } 
    v.value=33
    v.value=44
    v.value.should eq(44)
 end
 it "create a Dyn entry" do
    v=DynVar.new("eeee")
    @win.create {   w=entry(v) } 
    v.value="33"
    v.value="44"
    v.value.should eq("44")
 end
 it "create a Dyn entry" do
    v=DynVar.new(false)
    w=nil
    @win.create {   w=check_button("ee",v) } 
    v.value=true
    v.value=false
    v.value.should eq(false)
 end
=begin
 it "video" do
   puts "\n\n=============== Video test !!!!  ==================\nScratch possibility...\n\n"
   sleep 1
  @win.create do
    video_file="d:/usr/XT.avi"
    video_url="file:///#{video_file}"
    stack do
      @v=video(video_url,120,90)  {|progress| @prog && @prog.progress=progress*100 }
      flowi {
        buttoni("  Start  ") {  @v.play }
        buttoni("  Stop  ") {  @v.stop }
        @prog=slider(0,0,100.0) { |pos| @v && @v.progress= pos/100.0}
      }
      @v.play
      @v.destroy
    end 
   end
  end if defined?(Gst)
=end 
end