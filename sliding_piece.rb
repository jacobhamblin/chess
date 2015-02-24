require_relative 'piece.rb'

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
