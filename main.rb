
class GameBoard
  attr_accessor :game_board

  def initialize(rows = 8, columns = 8)
    @game_board = []
    rows.times do |row_number|
      row = []
      columns.times do |column_number|
        row << Node.new("#{row_number + 1}-#{column_number + 1}")
      end
      @game_board << row
    end
  end
end

class Node
  attr_accessor :previous_node, :number_of_moves
  attr_reader :position

  def initialize(position)
    @previous_node = nil
    @number_of_moves = nil
    @position = position
  end
end

class KnightsTravails
  attr_accessor :game_board
  attr_reader :start_position, :end_position

  def initialize
    @start_position = 'invalid'
    @end_position = 'invalid'
  end

  def start_game
    puts
    puts 'Welcome to Knights Travails.'
    @rows = ask_player_rows.to_i
    @columns = ask_player_columns.to_i
    @game_board = GameBoard.new(@rows, @columns)
    show_initial_board
    ask_player_start_position
    ask_player_end_position
    run_game
  end

  def show_initial_board
    height = @game_board.game_board.length
    width = @game_board.game_board[0].length

    puts
    seperator = '     '
    width.times do
      seperator << '______'
    end
    seperator << '_'
    puts seperator

    array = []
    height.times do |row_num|
      row = []
      width.times do |column_num|
        row << @game_board.game_board[row_num][column_num].position
      end
      array << row
    end
    array.each do |row|
      puts
      line = '     | '
      row.each do |cell|
        line << cell
        line << ' | '
      end
      puts line
      puts seperator
    end
    puts
  end

  def ask_player_start_position
    puts
    puts 'Please choose a starting position from the game board.'
    @start_position = validate('a starting')
  end

  def ask_player_end_position
    puts
    puts 'Please choose an ending position from the game board.'
    @end_position = validate('an ending')
  end

  def ask_player_rows
    puts 'Please choose how many rows you would like the board to have.'
    validate_row_or_column
  end

  def ask_player_columns
    puts 'Please choose how many columns you would like the board to have.'
    validate_row_or_column
  end

  def validate_row_or_column
    pattern = /\A[1-9]\z/
    valid = nil
    answer = ''
    while valid.nil?
      answer = gets.chomp
      valid = answer.match(pattern)
      next unless valid.nil?

      puts
      puts 'Your choice is invalid.'
      puts 'You must choose a number between 1 and 9.'
      puts
    end
    answer
  end

  def validate(type)
    pattern = /\A[1-9]-[1-9]\z/
    valid = nil
    while valid.nil?
      answer = gets.chomp
      valid = answer.match(pattern)
      next unless valid.nil?

      puts
      puts 'Your choice is invalid.'
      puts "Your choice must be in the form of '#-#'"
      puts "Please choose #{type} position."
      puts
    end
    answer.split('-').map(&:to_i)
  end

  def print_current_board_with_number_of_moves
    height = @game_board.game_board.length
    width = @game_board.game_board[0].length

    puts
    seperator = create_seperator(width)
    puts seperator

    array = []
    array = create_rows(array, height, width)

    print_rows(array, seperator)
    puts
  end

  def create_seperator(width)
    seperator = '     '
    width.times do
      seperator << '______'
    end
    seperator << '_'
  end

  def create_rows(array, height, width, game_board = @game_board)
    height.times do |row_num|
      row = []
      width.times do |column_num|
        row << if game_board.game_board[row_num][column_num].number_of_moves.nil?
                 '   '
               else
                 " #{game_board.game_board[row_num][column_num].number_of_moves} "
               end
      end
      array << row
    end
    array
  end

  def print_rows(array, seperator)
    array.each do |row|
      puts
      line = '     | '
      row.each do |cell|
        line << (cell.nil? ? '   ' : cell)
        line << ' | '
      end
      puts line
      puts seperator
    end
  end

  def run_game
    start_index_y = @start_position[0] - 1
    start_index_x = @start_position[1] - 1

    first_cell_index = [start_index_y, start_index_x]
    first_cell = get_current_cell(first_cell_index)
    first_cell.number_of_moves = 0
    first_cell.previous_node = 'start'
    queue = []
    queue << [first_cell]

    solve_board(queue)
    shortest_path = print_shortest_path
    print_current_board_with_path_to_ending_cell(shortest_path)
  end

  def print_current_board_with_path_to_ending_cell(shortest_path)
    new_board_for_path = GameBoard.new(@rows, @columns)
    create_shortest_path_board(new_board_for_path, shortest_path)
    puts
    seperator = create_seperator(@columns)
    puts seperator
    array = []
    array = create_rows(array, @rows, @columns, new_board_for_path)
    print_rows(array, seperator)
    puts
  end

  def create_shortest_path_board(new_board_for_path, shortest_path)
    shortest_path.each_with_index do |element, index|
      board_position = element.split('-').map(&:to_i)
      y = board_position[0] - 1
      x = board_position[1] - 1
      current_cell_index = []
      current_cell_index << y
      current_cell_index << x
      cell = get_current_cell(current_cell_index, new_board_for_path)
      cell.number_of_moves = index
    end
  end

  def get_current_cell(cell_index, game_board = @game_board)
    y = cell_index[0]
    x = cell_index[1]
    game_board.game_board[y][x]
  end

  def solve_board(queue)
    height_array = board_index_array(@game_board.game_board.length)
    width_array = board_index_array(@game_board.game_board[0].length)

    until queue.empty?
      current_cell = queue.shift

      current_cell_position = current_cell[0].position.split('-').map(&:to_i)
      current_cell_number_of_moves = current_cell[0].number_of_moves
      get_valid_moves(queue, current_cell_position, current_cell_number_of_moves, height_array, width_array)
    end
  end

  def get_valid_moves(queue, previous_cell_position, current_number_of_moves, height_array, width_array)
    new_number_of_moves = current_number_of_moves + 1

    y = previous_cell_position[0] - 1
    x = previous_cell_position[1] - 1

    temp_queue = []
    temp_queue << [y + 1, x + 2] if height_array.include?(y + 1) && width_array.include?(x + 2)
    temp_queue << [y + 1, x - 2] if height_array.include?(y + 1) && width_array.include?(x - 2)
    temp_queue << [y - 1, x + 2] if height_array.include?(y - 1) && width_array.include?(x + 2)
    temp_queue << [y - 1, x - 2] if height_array.include?(y - 1) && width_array.include?(x - 2)
    temp_queue << [y + 2, x + 1] if height_array.include?(y + 2) && width_array.include?(x + 1)
    temp_queue << [y + 2, x - 1] if height_array.include?(y + 2) && width_array.include?(x - 1)
    temp_queue << [y - 2, x + 1] if height_array.include?(y - 2) && width_array.include?(x + 1)
    temp_queue << [y - 2, x - 1] if height_array.include?(y - 2) && width_array.include?(x - 1)
    random_temp_queue = temp_queue.shuffle
    add_valid_moves_to_queue(queue, random_temp_queue, new_number_of_moves, previous_cell_position)
  end

  def add_valid_moves_to_queue(queue, temp_queue, new_number_of_moves, previous_cell_position)
    temp_queue.each do |cell_index|
      current_cell = get_current_cell(cell_index)

      next unless current_cell.number_of_moves.nil?

      current_cell.previous_node = previous_cell_position
      current_cell.number_of_moves = new_number_of_moves
      queue << [current_cell]
    end
  end

  def print_shortest_path
    puts
    puts "Starting from the starting position #{@start_position}"
    puts "and finishing at the end position #{@end_position}"
    puts 'the shortest path is:'
    y = @end_position[0] - 1
    x = @end_position[1] - 1

    current_cell = get_current_cell([y, x])
    shortest_path = []

    loop do
      shortest_path.unshift(current_cell.position)
      break if current_cell.previous_node == 'start'

      y = current_cell.previous_node[0] - 1
      x = current_cell.previous_node[1] - 1
      current_cell = get_current_cell([y, x])
    end
    puts shortest_path
    puts "The shortest path took #{shortest_path.length - 1} steps."
    shortest_path
  end

  def board_index_array(number)
    array = []
    number.times do |iteration|
      array << iteration
    end
    array
  end
end

if __FILE__ == $PROGRAM_NAME
  my_game = KnightsTravails.new
  my_game.start_game
end
