# Ruiby

[![Build Status](https://travis-ci.org/glurp/dsl-gtk.svg?branch=master)](https://travis-ci.org/glurp/dsl-gtk)
[![Gem Version](https://badge.fury.io/rb/Ruiby.png)](http://badge.fury.io/rb/Ruiby)
[![AppVeyor](https://ci.appveyor.com/api/projects/status/y6pqyq79ybcmj9ye?svg=true)](https://ci.appveyor.com/project/Glurp/dsl-gtk/branch/master)

A DSL for building simple GUI ruby application.
Based on gtk.


Resources
==========


Code: http://github.com/glurp/Ruiby

Doc: [Reference+Exemples.](https://rawgithub.com/glurp/Ruiby/master/doc.html)

Gem : https://rubygems.org/gems/Ruiby

Based on Ruby-Gmome2 :
* [Sources, Issues](https://github.com/ruby-gnome2/ruby-gnome2)
* [API](http://ruby-gnome2.osdn.jp/hiki.cgi?Ruby%2FGTK)


Status
======

NEW : 3.24.0 !!   28-11-2017 : Linear Gradient on canvas draw surfaces primitives

Now, plotters and dashboard can have beautiful background :)



TO DO  :

* [x] improve graphics quality on canvas : linear gradient
* [x] improve graphics quality on canvas : radial  gradient
* [x] improve graphics quality on canvas : transparency
* [ ] refactoring samples demos with last improve: dynvar/autoslot...
* [ ] resolve 100% gtk3 deprecated warning
* [ ] complete rspec => 99% coverage ?

Abandoned :

* [x] gadget API





Installation
============
1) system

Install Ruby 2.x  #  x>1


2) install Ruiby
(```gem install Ruiby``` will install ruby-gtk3 which install gtk3 libs)
```
> gem install Ruiby
```

Test it:

```
> ruiby_demo             # check good installation with gtk3 (default)
> ruiby_sketchi          # write and test ruiby code
```


Here a working gem config on windows (25-Sept-2016, Ruby  2.3.3p222) :
```
  did_you_mean-1.0.0
  pkg-config-1.2.3
  native-package-installer-1.0.4
  cairo-1.15.9
  glib2-3.1.8
  gobject-introspection-3.1.8
  gio2-3.1.8
  atk-3.1.8
  cairo-gobject-3.1.8
  pango-3.1.8
  gdk_pixbuf2-3.1.8
  gdk3-3.1.8
  rsvg2-3.1.8
  gtk3-3.1.8
  Ruiby-3.23.0
  gtksourceview3-3.1.8
```


Usage
======
DSL is usable via inherit, include, Ruiby.app bloc, or one-liner command.

By inherit:

```ruby
class Application < Ruiby_gtk
    def initialize(t,w,h)
        super(t,w,h)
    end
	def component()
	  stack do
		...
	  end
	end
	.....your code....
end
Ruiby.start { Win.new("application title",350,10) }

```

By include, calling ruiby-component() :

```ruby
class Win < Gtk::Window
	include Ruiby
    def initialize(t,w,h)
        super()
		add(@vb=VBox.new(false, 2))
		....
    end
	def add_a_ruiby_button()
		ruiby_component do
			append_to(@vb) do
				button("Hello Word #{@vb.children.size}") {
					add_a_ruiby_button()
				}
			end
		end
	end
end
Ruiby.start { Win.new("application title",350,10) }
```

Autonomous DSL, for  little application (most of demo in samples/ are
done with this pattern) :

```ruby
require  'Ruiby'
Ruiby.app do
	stack do
		. . .
	end
end
```
And, for very little application ('~' are replaced by guillemet):

```ruby

> ruiby   button(~Continue ? ~) "{  exit!(0) }"
> ruiby   fields([%w{a b},%w{b c},%w{c d}]) { "|a,b,c|" p [a,b,c] if a; exit!(a ?0:1) }
> ruiby -width 100  -height 300 -title "Please, select a file" \
             l=list(~Files :~);l.set_data Dir.glob(~*~) ;  \
             buttoni(~Selected~) { puts l.selection ; exit!(0) } ;\
			 buttoni(~Annul~) { exit!(1) }

```

Require
=======
Simple usage with gtk3 :

```ruby
require 'Ruiby'
```


Usage with Event Machine: load event-machine before Ruiby :

```ruby
require 'em-proxy'
require 'Ruiby'
```

Warning : EM.run is done when starting mainloop, after creation of window(s).
So, if you need initialization of event-machine callback, do it in component(), in a after(0):

```ruby
Ruiby.app do
  ....
  after(0) { EventMachine::start_server().. { ... } }
end
```

See samples/spygui.rb, for example of GUI with EM.


Threading
=========
Ruiby does not have confidence in gtk multi threading, so all Ruiby commands must be done in
main thread context. A Ruiby delegate is provided in Kernel module for support multi-threading

A Queue is polled by main-window thread :
* main window poll Queue , messages are proc to be instance_eval() in the main window context
* everywhere, a thread can invoke ```invoke_gui {ruiby code}```. this send to the main queue the proc,
   which will be evaluated asynchronously

instance_eval is avoided in ruiby. He is used only for thread invoker : gui_invoke().

```ruby
require_relative '../lib/Ruiby'
class App < Ruiby_gtk
    def initialize
        super("Testing Ruiby for Threading",150,0)
		threader(10)
		Thread.new { A.new.run }
    end
	def component()
	  stack do
		sloti(label("Hello, this is Thread test !"))
		stack { @lab=stacki { } }
	  end
	end # endcomponent

end
class A
	def run
 		loop do
		 	sleep(1) # thread...
			there=self
			gui_invoke { append_to(@lab) { sloti(
					label( there.aaa )  # ! instance_eval on main window
			)  } }
		end
	end
	def aaa() Time.now.to_s  end
end

Ruiby.start { App.new }

```


Observed Object/Variable
========================

Dynamic variable
----------------
Often, a widget (an entry, a label, a slider...) show the value of a ruby variable.
each time a code modify this variable, it must modify the widget, and vice-versa...
This is very tiring :)

With data binding, this notifications are done by the framework

So ```DynVar``` can be  used for representing a value variable which is dynamics, ie.
which must notify widgets which show the variable state.

So we can do :
```ruby
  foo=DynVar.new(0)
  entry(foo)
  islider(foo)
  ....
  foo.value=43  
  ....
```

That works ! the entry and the slider will be updated.

A move on slider will update foo.value and the entry.
Idem for a key in the entry : slider and foo.value will be updated.

if you want to be notified for your own treatment, you can observe a DynVar :

```ruby
  foo.observ { |v| @socket.puts(v.to_s) rescue nil }
```

Here, a modification of foo variable will be send on the network...

Warning !! the block will always be executed in the main thread context (mainloop gtk context).
So DynVar is a resource internal to Ruiby framework.

Widget which accept DynVar are : entry, ientry, islider, label, check_button,

```
must be extend to button, togglebutton, combo, radio_button ... list, grid,...
```


Dynamic Object
--------------

Often, this kind of Dyn variables are members of a 'record', which should be organized by an
Ruby Object (a Struct...)

So ```DynObject``` create a class, which is organized by a hash  :
* packet of variable name
* put initial value for each
* each variable will be a DynVar

```ruby
  FooClass=make_DynClass("v1" => 1 , "v2" => 2, "s1" => 'Hello...')
  foo=FooClass.new( "s1" => Time.now.to_s ) # default value of s1 variable is replaced
  ...
  label(" foo: ") ; entry(foo.s1)
  islider(foo.v1)
  islider(foo.v2)
  ....
  button("4x33") { Thread.new { foo.s1.value="s4e33" ; foo.v2.value=33 ; foo.v1.value=4} }
  ....
```

Dynamic Stock Object
--------------------
DynObject can be persisted to file system : use ```make_StockDynObject```, and
instantiate with an object persistent ID

```ruby
  FooClass=make_StockDynClass("v1"=> 1 , "v2" => 2, "s1" => 'Hello...')
  foo1=FooClass.new( "foo1" , "s1" => Time.now.to_s )
  foo2=FooClass.new( "foo2" , "s1" => (Time.now+10).to_s )
  ....
  button("Exit") { ruiby_exit} # on exit, foo1 and foo2 will been saved to {tmpdir}/<$0>.storage  
  ....
```
`make_StockDynObject` do both : Class creation **and** class instantiation.

```ruby
  foo=make_StockDynObject("v1"=> 1 , "v2" => 2, "s1" => 'Hello...')
  ....
  button(foo.s1) { foo.s1.value= prompt("new S1 value ?")}
  button("Exit") { ruiby_exit} # on exit, foo1 and foo2 will been saved to {tmpdir}/<$0>.storage  
  ....
```

Component
=========
Ruiby is not really object-orented : most of DSL words are simple method in Ruby_dsl module.

Sometime, this is not good enough :
* when a component must have many specific methods
* when component have (model) state : variable member must be used

So Component concept has been added (Fev 2016).It authorize to define a
class, child of AbstractComponent, which can be used by a DSL Word.

Components code seem very close to a Ruiby window : free constructor,
define ```component()``` method for draw the widgets

Create a component:
```ruby
class AAA < AbstractComposant
   def initialize(name)
      @name= name
      @state=1
   end
   def component()
    framei("Component Comp:#{@name}") do
      label_clickable("B#{@name}...") { @state=2 }
      entry(@name,4)
    end
   end
   def get_state() @state end
end
```

Define a word which instantiate a component of class AAA:
```ruby
module Ruiby_dsl
  def aaa(*args)
    c=install_composant(self,AAA.new(*args))
  end
end
```

Use the component:
```ruby
        c=nil
        stack {
           c=aaa "foo"
           flowi { aaa 1; aaa 2 }
        }
        button("?") { alert( c.get_state() ) }
```

A demo is at ```samples/composant.rb```.

TO-DO:
* Canvas and Plot must be converted to Component, soon :)
* Define ```destroy()```
* Hook for auto-generate DSL word
* Test Stock, Dynvar, threading,
* Tests, tests, test...


License
=======
Ruiby                   : LGPL, CC BY-SA

fafamfam rasters images : CC Attribution 4.0 http://www.famfamfam.com/

Crystal Clear icon set  : LGPL

Farm Fresh icon set     :  CC Attribution 3.0 License http://www.fatcow.com/free-icons

Exemples
========
See samples in "./samples" directory (run all.rb)
See at end of Doc reference : [Ex.](https://rawgithub.com/glurp/Ruiby/master/doc.html#code)
