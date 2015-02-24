require_relative 'piece.rb'

class Board
  attr_reader :grid

  def initialize
    @grid = Array.new(8) { Array.new(8) }

    populate

    #wk reference
    #bk reference
  end

  def in_bounds?(posn)
    posn.all? do |coordinate|
      coordiniate.between?(0,7)
    end
  end

  def occupied?(posn)
    !!whats_here(posn)
  end

  def whats_here(posn)
    @grid[posn[0]][posn[1]]
  end

  def []=(posn)
    @grid[posn[1]][posn[0]]
  end

  private
  def populate
    pawn_array = [].tap {|array| 8.times {|x| [x,1]}}
    piece_hash = {Pawn: pawn_array, Rook: [[0,0], [7,0]], Knight: [[1,0], [6,0]], Bishop: [[2,0], [5,0]], Queen: [[4,0]], King: [[3,0]] }

    populate_partial(piece_hash, :black)
    @grid.reverse! #just the outer layer
    populate_partial(piece_hash, :white)

    @white_king = self[3,0]
    @black_king = self[3,7]
  end

  def populate_partial(hash,color)
    piece_hash.keys.each do |piece_type|
      piece_hash[piece_type].each do |posn|
        self[posn] = Object.const_get(piece_type.to_s).new({color: color, board: self, position: posn})
      end
    end
  end
end
