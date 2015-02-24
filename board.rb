class Board
  attr_reader :grid

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
end
