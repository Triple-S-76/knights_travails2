require_relative '../main'
require 'stringio'

def capture_stdout
  original_std_out = $stdout
  $stdout = StringIO.new
  yield
  $stdout.string
ensure
  $stdout = original_std_out
end



describe GameBoard do
  it 'tests initialize method' do
    expect(subject.game_board[0][1].number_of_moves).to be_nil
    expect(subject.game_board[2][3].number_of_moves).to be_nil
    expect(subject.game_board[4][5].number_of_moves).to be_nil
    expect(subject.game_board[6][7].number_of_moves).to be_nil
    expect(subject.game_board[0][1].previous_node).to be_nil
    expect(subject.game_board[2][3].previous_node).to be_nil
    expect(subject.game_board[4][5].previous_node).to be_nil
    expect(subject.game_board[6][7].previous_node).to be_nil
    expect(subject.game_board[0][1].position).to eq('1-2')
    expect(subject.game_board[2][3].position).to eq('3-4')
    expect(subject.game_board[4][5].position).to eq('5-6')
    expect(subject.game_board[6][7].position).to eq('7-8')
  end
end

describe Node do
  it 'tests the initialize method' do
    subject = Node.new('2-2')
    expect(subject.previous_node).to be_nil
    expect(subject.number_of_moves).to be_nil
    expect(subject.position).to eq('2-2')
  end
end

describe KnightsTravails do
  context 'Game setup' do
    it '#initialize - tests the initialize method' do
      expect(subject.start_position).to eq('invalid')
      expect(subject.end_position).to eq('invalid')
    end

    it '#start_game - tests that methods are called' do
      game_board_double = instance_double(GameBoard)
      expect(subject).to receive(:ask_player_rows).once.and_return('9')
      expect(subject).to receive(:ask_player_columns).once.and_return('7')
      expect(GameBoard).to receive(:new).and_return(game_board_double).with(9, 7)
      expect(subject).to receive(:puts).twice
      expect(subject).to receive(:show_initial_board).once
      expect(subject).to receive(:ask_player_start_position).once
      expect(subject).to receive(:ask_player_end_position).once
      expect(subject).to receive(:run_game).once
      subject.start_game
    end

    it '#show_initial_board - tests the printing of the initial board' do
      subject.game_board = GameBoard.new
      expect(subject).to receive(:puts).exactly(27).times
      subject.show_initial_board
    end

    it '#ask_player_start_position' do
      expect(subject).to receive(:puts).twice
      expect(subject).to receive(:validate).once
      subject.ask_player_start_position
    end

    it '#ask_player_end_position' do
      expect(subject).to receive(:puts).twice
      expect(subject).to receive(:validate).once
      subject.ask_player_end_position
    end

    it '#ask_player_rows' do
      expect(subject).to receive(:puts).with('Please choose how many rows you would like the board to have.')
      expect(subject).to receive(:validate_row_or_column).once
      subject.ask_player_rows
    end

    it '#ask_player_columns' do
      expect(subject).to receive(:puts).with('Please choose how many columns you would like the board to have.')
      expect(subject).to receive(:validate_row_or_column).once
      subject.ask_player_columns
    end

    it '#validate_row_or_column - 1 valid answer' do
      expect(subject).not_to receive(:puts)
      expect(subject).to receive(:gets).once.and_return('9')
      answer = subject.validate_row_or_column
      expect(answer).to eq('9')
    end

    it '#validate_row_or_column - 1 invalid answer & 1 valid answer' do
      expect(subject).to receive(:puts).exactly(4).times
      expect(subject).to receive(:gets).twice.and_return('10', '1')
      answer = subject.validate_row_or_column
      expect(answer).to eq('1')
    end

    it '#validate_row_or_column - 4 invalid answers & 1 valid answer' do
      expect(subject).to receive(:puts).exactly(16).times
      expect(subject).to receive(:gets).exactly(5).times.and_return('55', '10', '0', 'word', '3')
      answer = subject.validate_row_or_column
      expect(answer).to eq('3')
    end

    it '#validate - 1 valid entry' do
      expect(subject).to receive(:gets).and_return('2-8')
      answer = subject.validate('a starting')
      expect(answer).to eq([2, 8])
    end

    it '#validate - 2 invalid entries then 1 valid entry' do
      expect(subject).to receive(:gets).and_return('33', 'invalid', '3-6')
      expect(subject).to receive(:puts).exactly(10).times
      answer = subject.validate('a starting')
      expect(answer).to eq([3, 6])
    end

    it '#validate - 9 invalid entries then 1 valid entry' do
      expect(subject).to receive(:gets).and_return('123', '34', '7', '2', 't', '22-3', '2-22', '2.3', 'invalid', '4-2')
      expect(subject).to receive(:puts).exactly(45).times
      answer = subject.validate('an ending')
      expect(answer).to eq([4, 2])
    end

    it '#print_current_board_with_number_of_moves' do
      seperator_double = double('seperator double')
      my_game = KnightsTravails.new
      my_game.game_board = GameBoard.new(6, 4)
      expect(my_game).to receive(:puts).exactly(3).times
      expect(my_game).to receive(:create_seperator).with(4).and_return(seperator_double)
      expect(my_game).to receive(:create_rows).with([], 6, 4).once.and_return([])
      expect(my_game).to receive(:print_rows).with([], seperator_double).once

      my_game.print_current_board_with_number_of_moves
    end

    it '#create_seperator - tests with a width of 4' do
      expected_seperator = '     _________________________'
      expect(subject.create_seperator(4)).to eq(expected_seperator)
    end

    it '#create_seperator - tests with a width of 8' do
      expected_seperator = '     _________________________________________________'
      answer = subject.create_seperator(8)
      expect(answer).to eq(expected_seperator)
    end

    it '#create_rows - height 2 and width 2' do
      my_game_board = GameBoard.new(2, 2)
      answer = subject.create_rows([], 2, 2, my_game_board)
      expect(answer).to eq([['   ', '   '], ['   ', '   ']])
    end

    it '#create_rows - height 8 and width 8' do
      my_game_board = GameBoard.new(8, 8)
      answer = subject.create_rows([], 8, 8, my_game_board)
      expect(answer).to eq(
        [
          ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
          ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
          ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
          ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
          ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
          ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
          ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   '],
          ['   ', '   ', '   ', '   ', '   ', '   ', '   ', '   ']
        ]
      )
    end

    it '#print_rows - height 2 and width 2' do
      array = [['   ', '   '], ['   ', '   ']]
      seperator = subject.create_seperator(2)

      expected_output = "\n     |     |     | \n     _____________\n\n     |     |     | \n     _____________\n"
      captured_output = capture_stdout do
        subject.print_rows(array, seperator)
      end

      expect(expected_output).to eq(captured_output)
    end

    it '#run_game' do
      my_game = KnightsTravails.new
      my_game.instance_variable_set(:@start_position, [6, 4])
      cell_double = double('first cell')
      expect(cell_double).to receive(:number_of_moves=).with(0)
      expect(cell_double).to receive(:previous_node=).with('start')
      expect(my_game).to receive(:get_current_cell).with([5, 3]).and_return(cell_double)
      expect(my_game).to receive(:solve_board).with([[cell_double]]).once
      expect(my_game).to receive(:print_shortest_path).and_return(99).once
      expect(my_game).to receive(:print_current_board_with_path_to_ending_cell).with(99).once
      my_game.run_game
    end

    it '#print_current_board_with_path_to_ending_cell' do
      my_game = KnightsTravails.new
      my_game.instance_variable_set(:@rows, 3)
      my_game.instance_variable_set(:@columns, 4)
      game_board_double = double(GameBoard)
      the_shortest_path = [[1, 1], [2, 3]]

      expect(GameBoard).to receive(:new).and_return(game_board_double).once
      expect(my_game).to receive(:create_shortest_path_board).with(game_board_double, the_shortest_path).once
      expect(my_game).to receive(:puts).exactly(3).times
      expect(my_game).to receive(:create_seperator).with(4).and_return(999).once
      expect(my_game).to receive(:create_rows).with([], 3, 4, game_board_double).and_return(101)
      expect(my_game).to receive(:print_rows).with(101, 999).once
      my_game.print_current_board_with_path_to_ending_cell(the_shortest_path)
    end

    it '#create_shortest_path_board' do
      my_game = KnightsTravails.new
      empty_game_board = GameBoard.new(9, 9)
      cell_double = double('cell')
      allow(cell_double).to receive(:number_of_moves=)
      shortest_path = %w["1-1 3-2 5-3 7-4 8-6 7-8 9-9]
      expect(my_game).to receive(:get_current_cell).exactly(7).times.and_return(cell_double)

      my_game.create_shortest_path_board(empty_game_board, shortest_path)
    end

    it '#get_current_cell' do
      my_game = KnightsTravails.new
      game_board_double = double(GameBoard)
      expect(game_board_double).to receive(:game_board).and_return('the correct cell')
      my_game.get_current_cell([4, 6], game_board_double)
    end

    it '#solve_board' do
      my_game = KnightsTravails.new
      empty_board = GameBoard.new(4, 4)
      my_game.instance_variable_set(:@game_board, empty_board)
      expect(my_game).to receive(:get_valid_moves).exactly(16).times.and_call_original

      starting_cell = my_game.get_current_cell([0, 0])
      starting_cell.previous_node = 'start'
      starting_cell.number_of_moves = 0
      my_game.solve_board([[starting_cell]])
    end

    it '#get_valid_moves' do
      my_game = KnightsTravails.new
      empty_board = GameBoard.new(4, 4)
      my_game.instance_variable_set(:@game_board, empty_board)
      expect(my_game).to receive(:add_valid_moves_to_queue).once
      height_array = [0, 1, 2, 3]
      width_array = [0, 1, 2, 3]
      my_game.get_valid_moves([], [1, 1], 0, height_array, width_array)
    end

    it '#add_valid_moves_to_queue' do
      my_game = KnightsTravails.new
      empty_board = GameBoard.new(8, 8)
      my_game.instance_variable_set(:@game_board, empty_board)
      expect(my_game).to receive(:get_current_cell).twice.and_call_original
      result = my_game.add_valid_moves_to_queue([], [[2, 1], [1, 2]], 1, [1, 1])
      expect(result).to eq([[2, 1], [1, 2]])
    end

    it '#print_shortest_path' do
      my_game = KnightsTravails.new
      finished_game_board = GameBoard.new(4, 4)
      finished_game_board.game_board[0][0].number_of_moves = 0
      finished_game_board.game_board[0][0].previous_node = 'start'
      finished_game_board.game_board[1][2].number_of_moves = 1
      finished_game_board.game_board[1][2].previous_node = [1, 1]
      finished_game_board.game_board[3][3].number_of_moves = 2
      finished_game_board.game_board[3][3].previous_node = [2, 3]
      my_game.instance_variable_set(:@game_board, finished_game_board)
      my_game.instance_variable_set(:@start_position, [1, 1])
      my_game.instance_variable_set(:@end_position, [4, 4])
      expect(my_game).to receive(:puts).exactly(6).times
      result = my_game.print_shortest_path
      expect(result).to eq(%w[1-1 2-3 4-4])
    end

    it '#board_index_array - 4 elements' do
      my_game = KnightsTravails.new
      result = my_game.board_index_array(4)
      expect(result).to eq([0, 1, 2, 3])
    end

    it '#board_index_array - 8 elements' do
      my_game = KnightsTravails.new
      result = my_game.board_index_array(8)
      expect(result).to eq([0, 1, 2, 3, 4, 5, 6, 7])
    end
  end
end
