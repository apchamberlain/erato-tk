#!/usr/bin/tclsh

#
#  Graphical Sieve of Eratosthenes with Tcl/Tk
#
#  Copyright (C) 2013  Alexander Park Chamberlain
#
#  Author: Alex Chamberlain <apchamberlain@gmail.com>
#  Version: 1.0
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.




package require Tk

if { $argc < 1 || [string length argv] < 1}  {
    set side 10
} else {
    set side $argv	
}

if { ![string is integer $side ] || $side < 1 } {
    puts "Please give a positive integer argument for the side of the box of primes."
    exit
}

set max [expr $side * $side]

set boxSize 30
set border 15
set padForButton 50
set windowSizeX [expr $boxSize * $side + $border * 2]
set windowSizeY [expr $windowSizeX + $padForButton]

set pugnacious_purple #aa02dd
set jaundiced_yellow  #bbbb00
set gruesome_green    #00aa00

# Make window a little bigger than all the little squares, prettier.

canvas .c -height $windowSizeY -width $windowSizeX -background gray
pack .c


proc box { n fillcolor textcolor} {
    global side
    global boxSize 
    global border
    set x [expr (($n - 1) % $side) * $boxSize]
    set y [expr int(($n - 1)/ $side) * $boxSize]
    # square where UL = (x + border, y + border)
    # down to LR = ((x + boxSize + border, y + boxSize + border)
    .c create rectangle [expr $x + $border] [expr $y + $border] \
	[ expr $x + $boxSize + $border ] [ expr $y + $boxSize + $border ] \
	-width 3 -outline black -fill $fillcolor
    # numbers inside
    .c create text [expr $x + $border + $boxSize / 2] \
	[expr $y + $border + $boxSize / 2] -fill $textcolor \
	-text $n
}


for {set i 1} {$i <= $max} {incr i} {
    box $i $pugnacious_purple white
}

# Start and Exit buttons
set exitButton [ button .b1 -text "Exit" -command {exit} -background gray]
place $exitButton -x [expr $windowSizeX / 2 + 5] -y [expr $windowSizeY - $border - $padForButton / 2 ]
update

set startButton [ button .b2 -text "Start" -command {go 1} -background gray]
place $startButton -x [expr $windowSizeX / 2 - 60] -y [expr $windowSizeY - $border - $padForButton / 2 ]
update


proc go {nop} {
    global max
    global pugnacious_purple
    global jaundiced_yellow
    global gruesome_green
    
    # Algorithm: Build list of integers from 1 to max, remove not-primes
    # from list, then output list.
    
    # Create initial array of possible primes at same time as
    # initial graphic, a square of squares, $side on a side, total $max, numbers
    # in the squares, background purple, text white.
    # Assuming (0,0) is at top left---i.e., move down screen as y increases.
    
    set ints {}
    for {set i 1} {$i <= $max} {incr i} {
	lappend ints $i
	set markedNotAPrime($i) 0;	# for graphics
	box $i $pugnacious_purple white
    }
    
    update
    after 50
    for {set factor 2 } {$factor <= [ expr sqrt($max) ]} { incr factor } {
	if { !$markedNotAPrime($factor) } {
	    box $factor black white
	    # Flash the background green
	    box $factor $gruesome_green white
	    update
	    after 200
	    # Back to purple
	    box $factor $pugnacious_purple white
	    update
	    after 100
	}

	for {set i [expr $factor * 2]} {$i <= $max} {incr i $factor} {
	    set indexOfMultiple [ lsearch -exact $ints $i ]
	    if { $indexOfMultiple >= 0 }  {
		# Check to see if box for $i has already been filled.
		if { !$markedNotAPrime($i) } {
		    # Flash the number, then block out the square
		    box $i $pugnacious_purple white
		    update
		    after 150
		    box $i black $jaundiced_yellow
		    update
		    after 100
		    box $i black black
		    update
		    after 90
		    box $i black $jaundiced_yellow
		    update
		    after 50
		    box $i black black
		    update
		    after 25
		    set markedNotAPrime($i) 1
		}
		set ints [ lreplace $ints $indexOfMultiple $indexOfMultiple ]
	    }
	}
    }
}

