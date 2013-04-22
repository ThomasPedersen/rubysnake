#!/usr/bin/env ruby

# RubySnake - The classic snake-game running on ruby
# Version 0.0.1
# Copyright (C) 2008 Thomas Wahl Pedersen
# www.thomaspedersen.org
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/.

require 'gosu'
require 'yaml'


class Snake < Gosu::Window
  module Z
    Text = 1
  end

  settings = YAML.load_file "config.yaml"
  WIDTH = settings["screen_width"]
  HEIGHT = settings["screen_height"]

  TEXT_COLOR = Gosu::Color::WHITE

  # Not used yet
  GRID_WIDTH = settings["grid_width"]
  GRID_HEIGHT = settings["grid_height"]

  def initialize
	  super(WIDTH, HEIGHT, false, 100)

    @font = Gosu::Font.new(self, Gosu.default_font_name, 50)

	  @apple_pos = { :x => 20, :y => height/32 }

	  @snake = []
	  @direction = :right
	  @pos = {:x => 6, :y => height/32}
	  6.times { |n| @snake << {:x => -n, :y => height/32} }
    @paused = false
  end

  def update
    return if @paused

    @pos[:x] += case @direction
                when :left  then -1
                when :right then 1
                else 0
                end

    @pos[:y] += case @direction
                when :up   then -1
                when :down then 1
                else 0
                end


    if @snake.index({ :x => @pos[:x], :y => @pos[:y] })
      you_died
    end

    @snake << { :x => @pos[:x], :y => @pos[:y] }

    if @pos == @apple_pos then
      @snake.unshift({ :x => @pos[:x], :y => @pos[:y] })
      while @snake.index(@apple_pos)
        @apple_pos = { :x => rand(width/16), :y => rand(height/16) }
      end
    end

    @snake.shift
  end

  def you_died
    @text = "You died!"
    @draw_text_now = true
    p @text
    @paused = true
  end

  def button_down(key)
    case key
      when Gosu::KbSpace  then @paused = !@paused
      when Gosu::KbEscape then close
      when Gosu::KbLeftMeta && Gosu::KbQ  then close
      when Gosu::KbRightMeta && Gosu::KbQ then close
    end

    @direction = case key
                   when Gosu::KbRight then @direction == :left ? @direction : :right
                   when Gosu::KbUp    then @direction == :down ? @direction : :up
                   when Gosu::KbLeft  then @direction == :right ? @direction : :left
                   when Gosu::KbDown  then @direction == :up ? @direction : :down
                   else @direction
                 end
   end

  def draw
    snake_color = Gosu::Color.new(0xff00ff00)
    apple_color = Gosu::Color.new(0xffff0000)
    @snake.each do |part|
     draw_quad(
                 part[:x]*16, part[:y]*16, snake_color,
                 part[:x]*16+16, part[:y]*16, snake_color,
                 part[:x]*16, part[:y]*16+16, snake_color,
                 part[:x]*16+16, part[:y]*16+16, snake_color
              )
    end

    draw_quad(
               @apple_pos[:x]*16, @apple_pos[:y]*16, apple_color,
               @apple_pos[:x]*16+16, @apple_pos[:y]*16, apple_color,
               @apple_pos[:x]*16, @apple_pos[:y]*16+16, apple_color,
               @apple_pos[:x]*16+16, @apple_pos[:y]*16+16, apple_color
            )

    if @draw_text_now
      draw_text(@text)
      @draw_text_now = false unless @paused 
    end
  end

  def draw_text(text)
    text_width = @font.text_width(text)

    @font.draw(
      text,
      (WIDTH / 2) - (text_width / 2),
      (HEIGHT / 2) - 10,
      Z::Text,
      1.0, 1.0,
      TEXT_COLOR
    )
  end
end

game = Snake.new
game.show


# bugs:
# - when crossing the border of the window (the walls) the snake does not die
# - the game does not reset when the snake dies
# - if, for instance, the up and left keys are pushed quickly, the snake can
#   "run" on top of itself
# - show score
# - when snake dies, display "Press Space to Replay" and reset the game
# - change from hard-coded window sizes to grid size
