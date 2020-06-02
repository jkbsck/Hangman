# HANGMAN
#
# PSEUDO: 1. Computer loads one 5-12 character word from dictionary
#         2. Display score after every guess
#         3. Play round - player guesses letter, if it matches reveal the letter in @word array
#            if not take one life
#         4. Do saves
#         5. Do loads
#         6. Do other menu options

module GameTools
  def display_score
    #puts "secret word temporary: #{@secret_word}"
    puts "\n\t\t\tword: #{@word.join}\n\n" if @word.class == Array
    puts "\n\t\t\tword: #{@word}\n\n" if @word.class == String
    puts "guessed_chars: #{@guessed_chars.join(' ')}" if @guessed_chars.class == Array
    puts "guessed_chars: #{@guessed_chars}" if @guessed_chars.class == String
    puts "lives: #{@lives}"
  end

  def check_guess
    if @secret_word.include? @actual_letter # if the guess is correct
      @secret_word.each_with_index do |char, index|
        @word[index] = @secret_word[index] if @actual_letter == @secret_word[index]
      end
      puts "Secret word includes letter #{@actual_letter}"
    else  # if the guessis incorrect
      @lives -= 1
      puts "Secret word does not include letter #{@actual_letter}"
    end

    @guessed_chars.push @actual_letter unless @guessed_chars.include? @actual_letter  # update used chars
    @actual_letter = nil
  end

  def menu
    puts "Press '2' to save the game"
    puts "Press '3' to load the game"
    puts "Press '4' to return to the game"
    puts "Press '5' to exit"

    char = gets.chomp[0]

    case char
    when '2'
      save_game
    when '3'
      load_game
    when '4'
      
    when '5'
      @lives = 0
    end
  end

  def save_game
    puts "Name of your save:"
    save_name = gets.chomp
    File.open("saved_games.txt") do |file|
      while file.read.include? save_name
        puts "Already exists. Try another name."
        save_name = gets.chomp
      end
    end
    File.write("saved_games.txt",
      "#{save_name}$#{@secret_word}%#{@word}^#{@guessed_chars}&#{@lives}\n",
      mode: "a")
  end

  def load_game
    puts "Choose number of saved game you want to play: "
    File.open("saved_games.txt") do |file|
      file.readlines.each_with_index do |line, i|
        puts "#{i+1}. #{line[0...line.index('$')]}"
      end
      game_to_load = gets.chomp.to_i
      file.rewind
      file.readlines.each_with_index do |line, i|
        if game_to_load - 1 == i
          puts @secret_word = line[line.index('$') + 1...line.index('%')]
          puts @word = line[line.index('%') + 1...line.index('^')]
          puts @guessed_chars = line[line.index('^') + 1...line.index('&')]
          puts @lives = line[line.index('&') + 1...line.index('\\n')].to_i
        end
      end
    end
  end
end

class Game
  include GameTools

  def initialize
    x = rand(0..61405)
    dictionary = File.open("5desk.txt", "r")

    dictionary.each_with_index do |line, index|
      if index == x
        if line.length > 5 && line.length <= 12
          @secret_word = line.downcase.strip.split('')
        else
          x = rand(index..61405)
        end
      end
    end
    
    @word = Array.new(@secret_word.length, '_')
    @guessed_chars = Array.new
    @lives = 7
  end

  def play_game
    while (@word.include? '_') && (@lives > 0)
      self.display_score
    
      self.play_round
    end

    puts "You won, secret word was: #{@secret_word.join}" if @lives > 0
    puts "You lose, secret word was: #{@secret_word.join}" if @lives == 0
  end

  def play_round
    puts "___________________________________________________________________________"
    puts "___________________________________________________________________________"
    puts "Press '1' for menu\n"
    until @actual_letter =~ /[a-z]/
      puts "Guess letter: "
      @actual_letter = gets.chomp.downcase[0]  # if string has more chars, take the first one
      
      if @actual_letter == '1'
        self.menu
        break
      end

      puts "Wrong input." unless @actual_letter =~ /[a-z]/
    end
    puts "actual_letter: #{@actual_letter}"
  
    self.check_guess unless @actual_letter == '1'

    puts "Press '1' for menu"
  end
end

game = Game.new

game.play_game

# Should be serialized this way

# p a = Marshal.dump(game)
# unless File.exist?('test_save.txt')
#   File.open("test_save.txt", "w") {|f| f.write(a)}
# end
# b = ''
# if File.exist?('test_save.txt')
#   File.open("test_save.txt", "r") {|f| b = f.read}
#   p b
# end
