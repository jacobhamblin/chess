require 'byebug'

class Piece
  attr_reader :color, :position, :symbol
  attr_writer :position

  def initialize(options = {})
    @position = options[:position]
    @symbol = NotImplementedError.new
    @color = options[:color]
    @board = options[:board]
  end

  def moves
    raise NotImplementedError.new
  end

  def valid_move?(cand_square)
    if !moves.include?(cand_square)
      return false
    elsif !@board.in_bounds?(cand_square)
      return false #out of the inner 'times' loop
    elsif @board.occupied?(cand_square)
      #debugger
      piece_color = @board.whats_here(cand_square).color
      case piece_color
      when @color
        return false
      when @color == :white ? (:black) : (:white)
        return true
      else
        raise TypeError("Piece color is misbehaving")
      end
    else #valid move and not blocked afterward
      return true
    end
  end

  def deep_dup
    options = {position: @position, symbol: @symbol, color: @color, board: @board}

    self.class.new(options)
  end

end
