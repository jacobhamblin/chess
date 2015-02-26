require_relative './board.rb'
require 'socket'
require 'json'

class Game
  def initialize
    @board = Board.new
  end

  def display
    puts @board.render
  end

  def play
    current_player = :white
    puts "\ec"
    puts "\nwhite plays first.\n\n"
    sleep(2)
    puts "\ec"
    loop do
      if @board.checkmate?(current_player)
        puts "Checkmate! #{current_player.to_s.capitalize} loses.\n\n"
        display
        break
      elsif @board.in_check?(current_player)
        display
        puts "\n#{current_player.to_s.capitalize} is in check!"
      end
      play_turn(current_player)
      current_player = (current_player == :black) ? :white : :black
    end
  end

  def play_turn(color)
    display
    puts "\nGive coordinates for the piece to be moved. (x,y)"
    from_coordinates = gets.chomp.split(",").map(&:strip).map(&:to_i)
    puts "Give coordinates for the position it should move to. (x,y)"
    to_coordinates = gets.chomp.split(",").map(&:strip).map(&:to_i)

    my_piece?(color,from_coordinates)
    @board.move(from_coordinates, to_coordinates)

  rescue InvalidMoveException => e
    puts "Invalid Move: #{e.to_s}"
    retry

  rescue ArgumentError => e
    puts "Badly formed coordinate; Provide your coordinate formatted x,y"
    retry
  end

  def my_piece?(color, coordinates)
    unless @board.occupied?(coordinates) && @board.whats_here(coordinates).color == color
      raise InvalidMoveException.new("This space does not have one of your pieces!")
    else
      true
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  g = Game.new
  g.play
end
