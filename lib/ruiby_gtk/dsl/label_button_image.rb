# Creative Commons BY-SA :  Regis d'Aubarede <regis.aubarede@gmail.com>
# LGPL

module Ruiby_dsl
  
  # create a bar (vertical or horizontal according to stack/flow current container) 
  def separator(width=1.0)  
    autoslot()
    sloti( Separator.new(
      @lcur.last.orientation==Gtk::Orientation::VERTICAL ? 
        Gtk::Orientation::HORIZONTAL : Gtk::Orientation::VERTICAL))  
  end
  
  def _dyn_label(var,option={}) 
    w=  label(var.value.to_s,option) 
    var.observ { |v| w.text = v.to_s }
    w
  end

  # create  label, with text (or image if txt start with a '#')
  # spatial option : isize : icon size if image (menu,small_toolbar,large_toolbar,button,dnd,dialog)
  def label(text,options={})
    if DynVar === text
      return _dyn_label(text,options)
    end
    l=_label(text,options)
    attribs(l,options)
  end
  def labeli(text,options={}) sloti(label(text,options)) end 
  
  def _label(text,options={})
    l=if text && text[0,1]=="#"
      get_image_from(text[1..-1],options[:isize]||:button);
    else
      Label.new(text);
    end
  end

  # create a icon with a raster file 
  # option can specify a new size : :width and :height, or :size  (square image)
  def image(file,options={})
    im=if File.exists?(file)
      pix=get_pixmap(file)
      pix=pix.scale(options[:width],options[:height],Gdk::Pixbuf::INTERP_BILINEAR) if options[:width] && options[:height]
      pix=pix.scale(options[:size],options[:size],Gdk::Pixbuf::INTERP_BILINEAR)  if options[:size] 
      Image.new(pixbuf: pix)
    else
      label("? "+file)
    end
    options.delete(:size)
    attribs(im,options)
  end
  # create a one-character size space, (or n character x n line space)
  def space(n=1) label(([" "*n]*n).join("\n"))  end
  def spacei(n=1) labeli(([" "*n]*n).join("\n"))  end
  def bourrage(n=1) n.times { label(" ") }  end

  # create  button, with text (or image if txt start with a '#')
  # block argument is evaluate at button click
  def button(text,option={},&blk)
    if text && text[0,1]=="#"
      b=Button.new(:label => nil, :mnemonic => nil, :stock_id => nil);
      text,tooltip=text[1..-1].split("//")
      b.set_image( get_image(text) )
      if tooltip
        b.has_tooltip= true
        b.tooltip_text=tooltip  
      end
    else
      b=Button.new(:label => text, :mnemonic => nil, :stock_id => nil);
    end
    b.signal_connect("clicked") { |e| blk.call(e) rescue error($!) } if blk
    apply_options(b.child,option)
    attribs(b,option)
  end 
  
  # create  button, with text (or image if txt start with a '#')
  # block argument is evaluate at button click, slotied :
  #  packed without expand for share free place
  def buttoni(text,option={},&blk) sloti(button(text,option,&blk)) end 

  # a button for show source code of application.
  # usefule for demos app
  def show_source
    label_clickable("Show source...") { Editor.new(self,$0,500) }
  end

  # a label clikable
  # label_button("hello") { alert(Time.now.to_s) }
  def label_clickable(text,config={},&b)
     pclickable(proc { b.call()} ) { label(text) }  
  end


  # Create a horizontal bar with a stick which can be moved.
  # block (if defined) is invoked on each value changed
  # w.proess=n can force current position at n
  #
  def slider(start=0.0,min=0.0,max=1.0,options={})
    fslider(start,{min: min, max: max, by: options[:by]||1}.merge(option))
  end
  
  def fslider(value=0,option={},&b)
    if DynVar === value
      return _dyn_fslider(value,option,&b)
    end
    w=Scale.new(:horizontal,option[:min],option[:max],option[:by])
    w.set_value(value ? value : 0)
    w.set_digits(option[:decimal]) if option[:decimal]
    w.signal_connect(:value_changed) { || b.call(w.value)  rescue error($!) } if block_given?
    w.define_singleton_method(:progress=) { |value| w.set_value(value) }
    attribs(w,option)   
  end
  def _dyn_fslider(var,option,&blk) 
    w=  block_given? ?  fslider(var.value,option,&blk) : fslider(var.value,option) { |v| var.value=v }
    var.observ { |v| w.set_value(v) }
    attribs(w,option)   
    w
  end
  
  # Show the evolution if a numeric value. Evolution is a number between 0 and 1.0
  # w.progress=n  force current evolution 
  def progress_bar(start=0,options)
   w=Gtk::ProgressBar.new
   w.define_singleton_method(:progress=) { |fract| w.fraction=fract }
   w.fraction=start
   attribs(w,{})
  end
  def levelbar(start=0,options)
   w=Gtk::LevelBar.new
   # TODO set value/progress/BynVar
   attribs(w,{})
  end
  # specific to gtk : some widget like label can't support click event, so they must
  # be contained in a clickable parent (EventBox)
  #  
  # Exemple: clickable(:callback_click_name) { label(" click me! ") }
  #
  # click callback  is definied by a method name.
  # see pclickable for callback by closure.
  def clickable(method_name,&b) 
    _accept?(:layout)
    eventbox = Gtk::EventBox.new
    eventbox.events =Gdk::EventMask::BUTTON_PRESS_MASK
    ret=_cbox(true,eventbox,{},true,&b) 
    #eventbox.realize
    eventbox.signal_connect('button_press_event') { |w, e| self.send(method_name,ret)  rescue error($!) }
    ret
  end

  # specific to gtk : some widget like label can't support click event, so they must
  # be contained in a clickable parent (EventBox)
  #
  # Exemple: pclickable(proc { alert true}) { label(" click me! ") }
  #
  # bloc is evaluated in a stack container
  def pclickable(aproc=nil,options={},&b) 
    _accept?(:layout)
    eventbox = Gtk::EventBox.new
    eventbox.events = Gdk::EventMask::BUTTON_PRESS_MASK
    ret=_cbox(true,eventbox,{},true,&b) 
    #eventbox.realize
    eventbox.signal_connect('button_press_event') { |w, e| aproc.call(w,e)  rescue error($!)  } if aproc
    apply_options(eventbox,options)
    ret
  end
  # as pclickable, but container is a stacki
  # pclickablei(proc { alert("e") }) { label("click me!") }
  def pclickablie(aproc=nil,options={},&b) 
    _accept?(:layout)
    eventbox = Gtk::EventBox.new
    eventbox.events = Gdk::EventMask::BUTTON_PRESS_MASK
    ret=_cbox(false,eventbox,{},true,&b) 
    #eventbox.realize
    eventbox.signal_connect('button_press_event') { |w, e| aproc.call(w,e)  rescue error($!)  } if aproc
    apply_options(eventbox,options)
    ret
  end
  
end