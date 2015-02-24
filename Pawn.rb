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
