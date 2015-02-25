require_relative './board.rb'

class Game
  def initialize
    @board = Board.new
    # @player1 = HumanPlayer.new(color: :white)
    # @player2 = HumanPlayer.new(color: :black)
  end

  def display
    puts @board.render
  end

  def play
    current_player  = :white
    loop do
      puts "\ec"
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
    puts "Give coordinates for the piece to be moved. (x,y)"
    from_coordinates = gets.chomp.split(",").map(&:strip).map(&:to_i)
    puts "Give coordinates for the position it should move to. (x,y)"
    to_coordinates = gets.chomp.split(",").map(&:strip).map(&:to_i)

    my_piece?(color,from_coordinates)
    @board.move(from_coordinates, to_coordinates)

  rescue InvalidMoveException => e
    puts "Invalid Move: #{e.to_s}"
    retry
  end

  def my_piece?(color, coordinates)
    unless !@board[*coordinates].nil? && @board[*coordinates].color == color
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
