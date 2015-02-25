require_relative './pieces.rb'
#require 'byebug'

class InvalidMoveException < ArgumentError; end

class Board
  attr_reader :grid
  attr_accessor :black_king, :white_king

  def initialize(options = {})
    @grid = options[:grid] || Array.new(8) { Array.new(8) }
    @black_king = options[:black_king]
    @white_king = options[:white_king]

    populate unless options[:grid]
  end

  def in_bounds?(posn)
    posn.all? do |coordinate|
      coordinate.between?(0,7)
    end
  end

  def occupied?(posn)
    !!whats_here(posn)
  end

  def whats_here(posn)
    self[*posn]
  end

  def []=(x, y, value)
    @grid[y][x] = value
  end

  def [](x,y)
    @grid[y][x]
  end

  def in_check?(color)
    king = (color == :black ) ? @black_king : @white_king
    enemy_pawns = []
    @grid.flatten.compact.each do |piece|
      next if piece.color == color
      if piece.is_a?(Pawn)
        enemy_pawns << piece
        next
      end
      piece.moves.each do |space|
        if self[*space] == king
          return true
        end
      end
    end

    enemy_pawns.each do |pawn|
      return true if pawn.captures.any? { |space| self[*space] == king }
    end

    false
  end

  def checkmate?(color)
    return false unless in_check?(color)
    colors(color).each do |piece|
      return false if piece.moves.any? {|move| piece.valid_move?(move)}

      # return false if piece.moves.any? {|move| piece.valid_move?(move)}
    end

    true
  end

  def render
    accumulator_string = ""
    @grid.each do |row|
      row.each do |space|
        if space.nil?
          accumulator_string << " "
        else
          accumulator_string << space.symbol.to_s
        end
      end
      accumulator_string << "\n"
    end

    accumulator_string
  end

  def move(start, end_pos)
    piece = self[*start]
    raise InvalidMoveException.new("No piece at that location") if piece.nil?
    raise InvalidMoveException.new("That piece can't move there") unless piece.valid_move?(end_pos)

    move!(start, end_pos)
  end

  def move!(start, end_pos)
    piece = self[*start]
    self[*end_pos] = piece
    self[*start] = nil
    piece.position = end_pos

    piece.has_moved = true if piece.is_a?(Pawn)
  end

  def deep_dup
    new_grid = []
    new_board = Board.new({grid: new_grid})
    @grid.each do |row|
      new_grid << [].tap do |new_row|
        row.each do |space|
          if space.nil?
            new_row << nil
          else
            new_space = space.deep_dup
            new_space.board = new_board
            new_row << new_space
          end
        end
      end
    end
    new_board.white_king = new_board.colors(:white).find { |piece| piece.class == King }
    new_board.black_king = new_board.colors(:black).find { |piece| piece.class == King }

    new_board
  end

  def colors(color)
    @grid.flatten.compact.keep_if { |piece| piece.color == color }
  end

  private
  def populate
    populate_bottom()
    populate_top()

    @white_king = self[4,7]
    @black_king = self[4,0]
  end

  def populate_top()
    color = :black
    pawn_array = [].tap {|array| 8.times {|x| array << [x,1]}}
    piece_hash = {Pawn: pawn_array, Rook: [[0,0], [7,0]], Knight: [[1,0], [6,0]], Bishop: [[2,0], [5,0]], Queen: [[3,0]], King: [[4,0]] }

    piece_hash.keys.each do |piece_type|
      piece_hash[piece_type].each do |posn|
        #debugger
        self[*posn] = Object.const_get(piece_type.to_s).new({color: color, board: self, position: posn})
      end
    end
  end

  def populate_bottom()
    color = :white
    pawn_array = [].tap {|array| 8.times {|x| array << [x,6]}}
    piece_hash = {Pawn: pawn_array, Rook: [[0,7], [7,7]], Knight: [[1,7], [6,7]], Bishop: [[2,7], [5,7]], Queen: [[3,7]], King: [[4,7]] }

    piece_hash.keys.each do |piece_type|
      piece_hash[piece_type].each do |posn|
        #debugger
        self[*posn] = Object.const_get(piece_type.to_s).new({color: color, board: self, position: posn})
      end
    end
  end


end

def setup_checkmate
  b = Board.new

  b.move([5,1],[5,2])
  b.move([4,6],[4,4])
  b.move([6,1],[6,3])
  b.move([3,7],[7,3])
  puts b.render

  b
end

if __FILE__ == $PROGRAM_NAME

elsif 'pry' == $PROGRAM_NAME
  b = setup_checkmate
end
