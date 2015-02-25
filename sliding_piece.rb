require_relative './piece.rb'
require_relative './board.rb'

class SlidingPiece < Piece
  DIAGONALS = [[1,1],[1,-1],[-1,1],[-1,-1]]
  ORTHOGONALS = [[1,0],[0,1],[-1,0],[0,-1]]

  def moves
    possible_moves = []
    move_dirs.each do |dir|
      (1..7).each do |n|
        potential_posn = slid_position(dir,n)
        possible_moves << potential_posn
        unless keep_looking?(potential_posn)
          break
        end
      end
    end

    possible_moves.keep_if { |m| possible_move?(m) }
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

class Bishop < SlidingPiece
  def initialize(options)
    super
    @symbol = :B
  end

  def move_dirs
    DIAGONALS
  end
end

class Rook < SlidingPiece
  def initialize(options)
    super
    @symbol = :R
  end

  def move_dirs
    ORTHOGONALS
  end
end

class Queen < SlidingPiece
  def initialize(options)
    super
    @symbol = :Q
  end

  def move_dirs
    ORTHOGONALS + DIAGONALS
  end
end
