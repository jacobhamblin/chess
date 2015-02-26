require_relative './pieces.rb'
require 'colorize'

class InvalidMoveException < ArgumentError; end



class Board
  attr_reader :grid
  attr_accessor :black_king, :white_king

  PIECE_ROW = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]

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
    colors((color == :black ) ? :white : :black).each do |piece|
      piece.moves.each do |space|
        if self[*space] == king
          return true
        end
      end
    end

    false
  end

  def checkmate?(color)
    return false unless in_check?(color)
    colors(color).any? do |piece|
      piece.moves.any? {|move| piece.valid_move?(move)}
    end

    true
  end

  def render(highlight_from = nil, highlight_to = nil)
    accumulator_string = horizontal_coordinate_line

    @grid.each_with_index do |row, index|
      accumulator_string << "#{index} "
      row.each_with_index do |space, horizontal_index|
        unless [index, horizontal_index] == highlight_from || [index, horizontal_index] == highlight_to
          if space.nil?
            accumulator_string << color_background("  ",index, horizontal_index)
          else
            accumulator_string << color_background("#{space.symbol.to_s} ",index, horizontal_index)
          end
        else
          if space.nil?
            accumulator_string << color_background("  ",index, horizontal_index, true)
          else
            accumulator_string << color_background("#{space.symbol.to_s} ",index, horizontal_index, true)
          end
        end
      end
      accumulator_string << "\n"
    end
    accumulator_string << horizontal_coordinate_line


    accumulator_string
  end

  def horizontal_coordinate_line
    accumulator_string = "  "
    @grid.first.each_index {|index| accumulator_string << "#{index} "}
    accumulator_string << "\n"

    accumulator_string
   end

   def color_background(string,row,column,highlight = false)
    if highlight == true
      string.colorize(:color => :black, :background => :light_cyan)
    else
       case (row+column)%2
       when 0
         string.colorize(:color => :black, :background => :light_white)
       when 1
         string.colorize(:color => :black, :background => :white)
       end
    end
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

    true
  end

  def deep_dup
    new_grid = []
    new_board = Board.new({grid: new_grid})
    @grid.each do |row|
      new_grid << row.map do |piece|
        if piece.nil?
          nil
        else
          new_piece = piece.deep_dup
          new_piece.board = new_board

          new_piece
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
    populate_part(:white,7,6)
    populate_part(:black,0,1)

    @white_king = colors(:white).find {|piece| piece.class == King}
    @black_king = colors(:black).find {|piece| piece.class == King}
  end


  def populate_part(color, piece_row_index, pawn_row_index)
    pawn_row = [].tap {|array| 8.times {|x| array << [x,pawn_row_index]}}.map {|posn| Pawn.new({color: color, board: self, position: posn, has_moved: false})}
    piece_row = []

    PIECE_ROW.each_with_index do |piece, piece_index|
      piece_row << piece.new({color: color, board: self, position: [piece_index, piece_row_index]})
    end

    self.grid[piece_row_index] = piece_row
    self.grid[pawn_row_index] = pawn_row
  end

end

def setup_checkmate
  b = Board.new

  b.move([5,6],[5,5])
  b.move([4,1],[4,3])
  b.move([6,6],[6,4])
  b.move([3,0],[7,4])
  puts b.render

  b
end
