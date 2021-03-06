#!/usr/bin/ruby
# encoding: utf-8
# Creative Commons BY-SA :  Regis d'Aubarede <regis.aubarede@gmail.com>
# LGPL

# test background/foreground for label and button
# windows : ok with gtk3, nol with gtk2

require 'gtk3' if ARGV.size==1 
require_relative '../lib/Ruiby'

Ruiby.app title: "Color test for button/label" do
    a=nil
    stack {
      w=button("test for "+ (ARGV.size>0 ? "Gtk3" : "Gtk2"),{font:'Tahoma bold italic 34'}) { exit! }
      widget_properties
      flow { a=buttoni("(1)green+blue/red    ",{fg:"#007777",bg:"#FF0000"}) ;button("  default  ",{}) ;button("  default  ",{}) ;}
      flow { buttoni("red / green bold",{bg:"#00FF00",fg:"#FF0000",font:"Arial bold 32"}) ;button("red / blue",{}) ;button("red / blue",{}) ;}
      flow { label("red / blue",{bg:"#0000FF",fg:"#FF0000"}) ;label("red / blue",font:"Arial bold 32") ;label("red / blue",{}) ;}
      flow { label("red / green / Arial",{bg:"#00FF00",fg:"#FF0000",font:"Arial 32"}) ;label("red / blue",{}) ;label("red / blue",{}) ;}
      flow { properties("props of (1)",get_config(a)) ; properties("props of child of(1)",get_config(a.child))}
      button("dialog...") do
        dialog("title") {
          stack  { 
            fields([["prop1","1"],["prop1","2"],["properties1","3"]]) {|*avalues| alert(avalues.join(", "))}
            separator
          }
        }
      end
      button("dialog async...") do
        dialog_async("title",:response=> proc { ask("ok") }) {
          stack  { 
            label "without validations.."
            fields([["prop1","1"],["prop1","2"],["properties1","3"]]) 
            separator
          }
        }
      end
    }
end
