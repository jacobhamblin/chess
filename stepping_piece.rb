require_relative 'piece.rb'

class SteppingPiece < Piece
  def moves
    possible_moves = []
    steps.each do |step|
      possible_moves << stepped_position(step)
    end

    possible_moves.keep_if { |m| possible_move?(m) }
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
  ONE_STEP_EACH_WAY = [[1,1], [1,-1], [-1,1], [-1,-1], [1,0], [0,1], [-1,0], [0,-1]]

  def initialize(options)
    super
    @symbol = (color == :black) ? :♚ : :♔
  end

  def steps
    ONE_STEP_EACH_WAY
  end
end

class Knight < SteppingPiece
  KNIGHT_JUMP_EACH_WAY = [[2,1], [1,2], [-2,1], [-1,2], [-2,-1], [-1,-2], [2,-1], [1,-2]]

  def initialize(options)
    super
    @symbol = (color == :black) ? :♞ : :♘
  end

  def steps
    KNIGHT_JUMP_EACH_WAY
  end
end
