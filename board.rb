require_relative './pieces.rb'
#require 'byebug'

class InvalidMoveException < ArgumentError; end

class Board
  attr_reader :grid

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
    @grid.flatten.each do |piece|
      next if piece.nil?
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

  end

  private
  def populate
    pawn_array = [].tap {|array| 8.times {|x| array << [x,1]}}
    piece_hash = {Pawn: pawn_array, Rook: [[0,0], [7,0]], Knight: [[1,0], [6,0]], Bishop: [[2,0], [5,0]], Queen: [[4,0]], King: [[3,0]] }

    populate_partial(piece_hash, :black)
    @grid.reverse! #just the outer layer
    populate_partial(piece_hash, :white)

    @white_king = self[3,0]
    @black_king = self[3,7]
  end

  def populate_partial(hash,color)
    hash.keys.each do |piece_type|
      hash[piece_type].each do |posn|
        #debugger
        self[*posn] = Object.const_get(piece_type.to_s).new({color: color, board: self, position: posn})
      end
    end
  end
end

# b = Board.new
