class Piece
  attr_reader :color, :position, :symbol

  def initialize(options)
    @position = options[:position]
    @symbol = NotImplementedError.new
    @color = options[:color]
    @board = options[:board]
  end

  def moves
    raise NotImplementedError.new
  end

  private
  def valid_move?(cand_square)
    if !@board.in_bounds?(cand_square)
      return false #out of the inner 'times' loop
    elsif @board.occupied?(cand_square)
      piece_color = whats_here(cand_square).color
      case piece_color
      when piece_color == @color
        return false
      when piece_color != @color
        return true
      else
        raise TypeError("Piece color is misbehaving")
      end
    else #valid move and not blocked afterward
      return true
    end
  end
end
