require 'set'

class GhostGame
  MAX_LIVES = 5

  attr_reader :players, :dict, :fragment, :current_player, :previous_player, :lives_count

  def self.create_dictionary(filename)
    dictionary_a = File.readlines(filename).map(&:chomp)
    dictionary_a = dictionary_a.select { |word| word.length >= 3 }
    dictionary_a.to_set
  end

  def initialize(players)
    @players = players
    @dict = GhostGame.create_dictionary("ghost-dictionary.txt")
    @lives_count = init_score_card
    @fragment = ""
    @current_player = players.first
    @previous_player = nil
  end

  def init_score_card
    count = {}
    @players.each { |player| count[player] = 0 }
    count
  end

  def play
    setup
    until game_over?
      until round_over?
        puts "#{current_player.name}'s turn!"
        take_turn(current_player)
        puts "The word fragment now is: #{fragment}"
        update_player_rotation
        next_player!
      end
      puts "#{previous_player.name} formed a word: #{fragment}!"
      puts "Round ended!"
      @lives_count[previous_player] += 1
      update_standings
      @fragment = ""
    end
    display_winner
  end

  def update_player_rotation
    dead_count = lives_count.select { |k, v| v == MAX_LIVES }
    if dead_count.empty?
      return
    else
      dead_players = dead_count.keys
      dead_players.each { |player| @players.delete(player) }
    end
    nil
  end

  def display_winner
    lives_count.each do |k, v|
      if v == MAX_LIVES
        puts "#{k.name} loses!"
      else
        puts "#{k.name} wins!"
      end
    end
  end

  def update_standings
    ghost = "GHOST"
    @lives_count.each do |k, v|
      if v > 0
        puts "#{k.name} has #{ghost[0...v]}!"
      end
    end
  end

  def round_over?
    dict.include?(fragment)
  end

  def game_over?
    count = 0
    lives_count.each do |k, v|
      if v == MAX_LIVES
        count += 1
      end
    end
    return true if count == 2
  end

  def setup
    puts "Welcome to Ghost!"
    puts "Each player(s) begins with 5 lives(GHOST)."
    puts "Each player(s) will take turns adding a letter to the growing fragment until a word is formed."
    puts "If word is formed, the round ends and player loses a life!"
  end

  def next_player!
    @players.rotate!
    @current_player = players.first
    @previous_player = players.last
  end

  def take_turn(player)
    letter = nil
    until letter && valid_play?(letter)
      letter = player.get_input
      alert_invalid_move(letter) unless valid_play?(letter)
    end
    @fragment += letter
  end

  def alert_invalid_move(letter)
    puts "You just entered an invalid letter: #{letter}!"
    puts "Letter appended to the fragment does not start a word!"
  end

  def valid_play?(letter)
    temp_fragment = fragment + letter
    dict.any? { |word| word.start_with?(temp_fragment) }
  end
end

class HumanPlayer
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def get_input
    prompt
    input = gets.chomp.downcase
    until valid_input?(input)
      input = gets.chomp
    end
    input
  end

  def prompt
    print "Enter a letter: "
  end

  private

  def valid_input?(input)
    alphabet = ("a".."z").to_a
    return true if alphabet.include?(input)
  end
end

if __FILE__ == $PROGRAM_NAME
  puts "How many players?"
  num_of_players = Integer(gets.chomp)
  players = []
  num_of_players.times do |i|
    print "Enter a name: "
    current_name = gets.chomp
    players << HumanPlayer.new(current_name)
  end
  g = GhostGame.new(players)
  g.play
end
