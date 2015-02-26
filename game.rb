require_relative './board.rb'
require 'socket'
require 'json'
require 'yaml'

class Game
  def initialize
    @board = Board.new
    @selection = [0,0]
  end

  def display(highlight_from = nil, highlight_to = nil)
    puts "\ec"
    puts @board.render(highlight_from, highlight_to)
  end

  def play
    current_player = :white
    puts "\ec"
    puts "\nwhite plays first.\n\n"
    sleep(2)
    puts "\ec"
    loop do
      if @board.checkmate?(current_player)
        puts "Checkmate! #{current_player.to_s.capitalize} loses.\n\n"
        display
        break
      elsif @board.in_check?(current_player)
        display
        puts "\n#{current_player.to_s.capitalize} is in check!"
      end
      play_turn(current_player)
      current_player = (current_player == :black) ? :white : :black
    end
  end

  def get_char
    state = `stty -g`
    `stty raw -echo -icanon isig`

    STDIN.getc.chr
  ensure
    `stty #{state}`
  end

  def play_turn(color)
    from_coordinates, to_coordinates = [nil,nil]
    coords = [@selection, from_coordinates]

    loop do
      display(*coords)
      stroke = get_char
      case stroke
      when /[wasd]/
        move_selection(stroke)
        coords = [@selection, from_coordinates]
      when "\r", " "
        from_coordinates == nil ? (from_coordinates = @selection) : (to_coordinates = @selection)
        coords = [@selection, from_coordinates]
        if to_coordinates != nil
          my_piece?(color,from_coordinates.reverse)
          @board.move(from_coordinates.reverse, to_coordinates.reverse)
          return
        end
      when "\u0013" # ctrl+s
        save
      when "\u000C" # ctrl+l
        load
      when "\u0003" #ctrl+c
        exit
      else
        #nothing
      end
    end



  rescue InvalidMoveException => e
    puts "Invalid Move: #{e.to_s}"
    retry

  rescue ArgumentError => e
    puts "Badly formed coordinate; Provide your coordinate formatted x,y"
    retry
  end

  def move_selection(stroke)
    offsets = {
      w: [-1, 0],
      a: [0,-1],
      s: [1,0],
      d: [0, 1]
    }
    stroke = stroke.to_sym
    x, y = @selection
    x_shift, y_shift = offsets[stroke]
    pos = [x + x_shift, y + y_shift]
    @selection = pos if @board.in_bounds?(pos)
  end

  def my_piece?(color, coordinates)
    unless @board.occupied?(coordinates) && @board.whats_here(coordinates).color == color
      raise InvalidMoveException.new("This space does not have one of your pieces!")
    else
      true
    end
  end

  def save(name = "default")
    puts "Saving game '#{name}'..", ' '
    File.write(save_path(name), @board.to_yaml)
  end

  def load(name = "default")
    path = save_path(name)
    if File.exist?(path)
      puts "Loading game '#{name}'..", ' '
      contents = File.read(path)
      @board = YAML::load(contents)
      @board.display
    else
      puts "Cannot find load file '#{name}'"
    end
  end

  private

    def save_path(name)
      "./#{name}.yml"
    end

end

if __FILE__ == $PROGRAM_NAME
  g = Game.new
  g.play
end
