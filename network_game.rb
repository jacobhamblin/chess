require_relative './game.rb'

class NetworkGame < Game
  def initialize
    @board = Board.new
    if ARGV.empty?
      port = 3000
      @server = TCPServer.open("localhost", port)
      puts "Waiting on port #{port}"
      @connection = @server.accept
    else
      @server = nil
      @connection = TCPSocket.open( "localhost", ARGV.shift )
    end
  end

  def play
    puts "\ec"
    puts "\nwhite plays first.\n\n"
    sleep(2)
    puts "\ec"
    if @server.nil?
      @our_color = :black
      @our_turn = false
    else
      @our_color = :white
      @our_turn = true
    end

    loop do
      if @our_turn
        puts "\ec"
        if @board.checkmate?(@our_color)
          checkmate_string = "Checkmate! #{@our_color.to_s.capitalize} loses.\n\n"
          puts checkmate_string
          display
          @connection.puts checkmate_string
          break
        elsif @board.in_check?(@our_color)
          display
          puts "\n#{@our_color.to_s.capitalize} is in check!"
        end
        move_made = play_turn(@our_color)
        display
        @connection.puts send_message(move_made)
        @our_turn = false
      else
        move_made = read_message(@connection.gets.chomp)
        unless move_made.class == Array
          puts move_made
          break
        end
        @our_turn = play_opponents_turn(move_made)
      end

    end
  end

  def send_message(object)
    JSON.generate(object)
  end

  def read_message(string)
    JSON.parse(string)
  rescue
    return string
  end

  def play_opponents_turn(posn_pair)
    from_posn = posn_pair[0]
    to_posn = posn_pair[1]
    opponents_color = (@our_color == :white) ? :black : :white


    my_piece?(opponents_color,from_posn)
    @board.move(from_posn, to_posn)

  rescue InvalidMoveException => e
    puts "Invalid Move: #{e.to_s}"
    retry
  rescue ArgumentError => e
    puts "Badly formed coordinate; Provide your coordinate formatted x,y"
    retry
  end

  def play_turn(color)
  begin
    display
    puts "\nGive coordinates for the piece to be moved. (x,y)"
    from_coordinates = gets.chomp.split(",").map(&:strip).map(&:to_i)
    puts "Give coordinates for the position it should move to. (x,y)"
    to_coordinates = gets.chomp.split(",").map(&:strip).map(&:to_i)

    my_piece?(color,from_coordinates)
    @board.move(from_coordinates, to_coordinates)

  rescue InvalidMoveException => e
    puts "Invalid Move: #{e.to_s}"
    retry
  rescue ArgumentError => e
    puts "Badly formed coordinate; Provide your coordinate formatted x,y"
    retry
  end

    return [from_coordinates, to_coordinates]
  end


end

if __FILE__ == $PROGRAM_NAME
  g = NetworkGame.new
  g.play
end
