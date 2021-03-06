# Creative Commons BY-SA :  Regis d'Aubarede <regis.aubarede@gmail.com>
# LGPL
###############################################################################################
#            windows.rb : main ruiby windows  
###############################################################################################

class Ruiby_gtk < Gtk::Window
  include ::Ruiby_dsl
  include ::Ruiby_threader
  def initialize(title,w,h)
    super()
    $app=self unless defined?($app)
    init_threader()
    #threader(10) # must be call by user window, if necessary
    set_title(title)
    
    # set default size/position
    set_window_position Gtk::WindowPosition::CENTER  # default, can be modified by window_position(x,y)
    set_default_size(w,h)
    
    # set quit handler    
    signal_connect "destroy" do 
        if @is_main_window
          (EM.stop rescue nil) if defined?(EM) 
          @is_main_window=false
          Gtk.main_quit rescue nil
        end
    end
    # set default icon for application
    iconfn=Ruiby::DIR+"/../media/ruiby.png"
    #set_icon(name:  iconfn) if File.exists?(iconfn)
    
    # set Ctrl-Shift-h handler
    agroup = Gtk::AccelGroup.new
    agroup.connect(Gdk::Keyval::KEY_H, 
      Gdk::ModifierType::CONTROL_MASK | Gdk::ModifierType::SHIFT_MASK, 
      :visible) do |w| 
      terminal("Debug terminal for #{$0}")
    end
    add_accel_group(agroup)
    
    @lcur=[self]
    @ltable=[]
    @current_widget=nil
    @cur=nil
  
    begin
      component  
    rescue
      error("COMPONENT() : "+$!.to_s + " :\n     " +  $!.backtrace[0..10].join("\n     "))
      exit(1)
    end
	  Ruiby.apply_provider(self)
    begin
      show_all 
    rescue
      puts "Error in show_all : illegal state of some widget? "+ $!.to_s
    end
    if ARGV.any? {|v| v=="take-a-snapshot" }
      after(100) { 
        snapshot("#{Dir.exists?("media") ? "media/" : ""}snapshot_#{File.basename($0)}.png")
        after(100) { exit(0)  } 
      }
    end
  end
  # define a action when window is resized
  def on_resize(&blk)
    self.resizable=true
    signal_connect("configure_event") { blk.call } if blk
  end
  # define action when window is closed
  def on_destroy(&blk) 
        signal_connect("destroy") { blk.call }
  end
  # set taskbar icon for current window
  # filename must have absolute path
  def set_window_icon(filename)
    if File.exists?(filename)
      self.set_icon_from_file(filename)
    else
      error("set_xindow_icon() : file #{filename} do not exists !!!")
    end
  end
  def ruiby_exit()
    Gtk.main_quit 
  end
  def component
    raise("Abstract: 'def component()' must be overiden in a Ruiby class")
  end

  # change position of window in the desktop. relative position works only in *nix
  # system.
  def rposition(x,y)
    if x==0 && y==0
      set_window_position Gtk::WindowPosition::CENTER
      return
    elsif     x>=0 && y>=0
      gravity= Gdk::Gravity::NORTH_WEST
    elsif   x<0 && y>=0
      gravity= Gdk::Gravity::NORTH_EAST
    elsif   x>=0 && y<0
      gravity= Gdk::Gravity::SOUTH_WEST
    elsif   x<0 && y<0
      gravity= Gdk::Gravity::SOUTH_EAST
    end
    move(x.abs,y.abs)
  end
  # show or supress the window system decoration
  def chrome(on=false)
    set_decorated(on)
  end
end

# can be included by a gtk windows, for  use ruiby.
# do an include, and then call ruiby_component() with bloc for use ruiby dsl
module Ruiby  
  include ::Ruiby_dsl
  include ::Ruiby_threader
  include ::Ruiby_default_dialog
  
  # ruiby_component() must be call one shot for a window, 
  # it initialise ruiby.
  # then append_to(),append_before()...  can be use fore dsl usage
  def ruiby_component()
    init_threader()
    @lcur=[self]
    @ltable=[]
    @current_widget=nil
    @cur=nil
    begin
      yield
    rescue
      error("ruiby_component block : "+$!.to_s + " :\n     " +  $!.backtrace[0..10].join("\n     "))
      exit!
    end
	Ruiby.apply_provider(self)
	show_all
  end
end

class Ruiby_dialog < Gtk::Window 
  include ::Ruiby_dsl
  include ::Ruiby_default_dialog
  def initialize() end
end