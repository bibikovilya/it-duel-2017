require 'httparty'
require 'net/http'

class Click
  include HTTParty

  TOKEN = 'OAGRJDEKZVQQORBP'
  base_uri 'https://clickomania.anadea.info'

  format :json

  attr_accessor :size, :board, :moves

  def initialize(size)
    @size = size.first.to_i
    @count = size.last.to_i
    @moves = []
  end

  def get_game
    self.class.get('/game', { query: { size: @size, token: TOKEN } })
  end

  def send_result
    p '*'*42
    p @moves
    p '*'*42
    p self.class.post("/game/#{TOKEN}", { body: "success_moves=#{@moves}" })
  end

  def start
    # @count.times do
    while (true) do
      @moves = []

      response = get_game

      t = eval(eval(response.body)[:cells])
      @board = t

      solve
    end
  end

  def solve
    5.times do
      colors = @board.flatten.uniq
      colors.delete(-1)

      @board.each_with_index do |row, i|
        row.each_with_index do |col, j|
          color = @board[i][j]
          if colors.include?(color)
            colors.delete(color) if is_single(i, j)
          end
        end
      end

      if colors.empty?
        return
      else
        remove(colors.first)
      end
    end

    # =========================================

    send_result
  end

  def is_single(i, j)
    color = @board[i][j]

    if i < @size-1 && @board[i+1][j] == color
      return false
    elsif i > 0 && @board[i-1][j] == color
      return false
    elsif j < @size-1 && @board[i][j+1] == color
      return false
    elsif j > 0 && @board[i][j-1] == color
      return false
    else
      return true
    end
  end

  def remove(color)
    @board.each_with_index do |row, i|
      row.each_with_index do |col, j|
        if @board[i][j] == color
          @moves << [i, j]

          remove_cell(i, j)

          squeeze_board
        end
      end
    end
  end

  def remove_cell(i, j)
    color = @board[i][j]

    @board[i][j] = -1

    if i < @size-1 && @board[i+1][j] == color
      remove_cell(i+1, j)
    end
    if i > 0 && @board[i-1][j] == color
      remove_cell(i-1, j)
    end
    if j < @size-1 && @board[i][j+1] == color
      remove_cell(i, j+1)
    end
    if j > 0 && @board[i][j-1] == color
      remove_cell(i, j-1)
    end
  end

  def squeeze_board
    count = @board.count { |col| col.all? { |el| el == -1 } }
    @board.delete(Array.new(@size, -1))
    count.times { @board << Array.new(@size, -1) }

    @board.each do |col|
      count = col.count { |el| el == -1 }
      col.delete(-1)
      count.times { col.unshift(-1) }
    end
  end
end
