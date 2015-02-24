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
