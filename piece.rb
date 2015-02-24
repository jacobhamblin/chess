class Piece
  attr_reader :color, :position

  def initialize(options)
    @position = options[:position]
    @symbol = options[:symbol]
    @color = options[:color]
    @board = options[:board]
  end

  def moves
    raise NotImplementedError.new
  end

  def symbol
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

class SlidingPiece < Piece
  DIAGONALS = [[1,1],[1,-1],[-1,1],[-1,-1]]
  ORTHOGONALS = [[1,0],[0,1],[-1,0],[0,-1]]

  def moves
    possible_moves = []
    move_dirs.each do |dir|
      8.times do |n|
        potential_posn = slid_position(dir,n)
        if valid_move?(potential_posn)
          possible_moves << potential_posn
        end
        unless keep_looking?(potential_posn)
          break
        end
      end
    end

    possible_moves
  end

  def move_dirs
    #return an array of directions
    raise NotImplementedError.new
  end

  private
  def slid_position(direction, distance)
    [@position[0]+direction[0]*distance,
     @position[1]+direction[1]*distance]
  end

  def keep_looking?(space)
    @board.in_bounds?(space) && !@board.occupied?(space)
  end
end

class SteppingPiece < Piece
  def moves
    possible_moves = []
    steps.each do |step|
      potential_posn = stepped_position(step)
      if valid_move?(potential_posn)
        possible_moves << potential_posn
      end
    end
  end

  def steps
    raise NotImplementedError.new
  end

  def stepped_position(step)
    [@position[0]+step[0],
     @position[1]+step[1]]
  end
end

class Pawn < Piece
  DIAGONALS_UP = [[-1,1], [1,1]]
  UP = [0,1]
  UP_TWO = [0,2]
  DIAGONALS_DOWN = [[-1,-1], [1,-1]]
  DOWN = [0,-1]
  DOWN_TWO = [0,-2]

  def initialize
    @symbol = :P
    @has_moved? = false
    super
  end

  def moves




    #hasn't moved yet (2 spaces)
    #pieces to kill
    #obstruction in front

  end

end


class Bishop < SlidingPiece
  def initialize
    @symbol = :B
    super
  end

  def move_dirs
    DIAGONALS
  end
end

class Rook < SlidingPiece
  def initialize
    @symbol = :R
    super
  end

  def move_dirs
    ORTHOGONALS
  end
end

class Queen < SlidingPiece
  def initialize
    @symbol = :Q
    super
  end

  def move_dirs
    ORTHOGONALS + DIAGONALS
  end
end

class King < SteppingPiece
  ONE_STEP_EACH_WAY =   [[1,1],[1,-1],[-1,1],[-1,-1], [1,0],[0,1],[-1,0],[0,-1]]

  def initialize
    @symbol = :K
    super
  end

  def steps
    ONE_STEP_EACH_WAY
  end
end

class Knight < SteppingPiece
  KNIGHT_JUMP_EACH_WAY = [[2,1],[1,2],[-2,1],[-1,2], [-2,-1],[-1,-2], [2,-1], [1,-2]]

  def initialize
    @symbol = :N
  end

  def steps
    KNIGHT_JUMP_EACH_WAY
  end
end
