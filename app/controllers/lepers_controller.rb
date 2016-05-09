require 'open-uri'
require 'json'

class LepersController < ApplicationController
  def game
     @grid = Array.new(9) { ('A'..'Z').to_a[rand(26)] }
     @start_time = Time.now
  end

  def score
    @attempt = params[:attempt]
    @grid = params[:grid]
    @start_time = Time.parse(params[:start_time])
    @end_time = Time.now
    @time_taken = @end_time - @start_time
    @result = {time: @time_taken}
    @result[:translation] = get_translation(@attempt)
    @result[:score], @result[:message] = score_and_message(@attempt, @result[:translation], @grid, @result[:time])
  end

  def get_translation(word)
  response = open("http://api.wordreference.com/0.8/80143/json/enfr/#{word.downcase}")
  json = JSON.parse(response.read.to_s)
  json['term0']['PrincipalTranslations']['0']['FirstTranslation']['term'] unless json["Error"]
  end

  def compute_score(attempt, time_taken)
  (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def score_and_message(attempt, translation, grid, time)
  if translation
    if included?(@attempt.upcase, grid)
      score = compute_score(@attempt, time)
      [score, "well done"]
    else
      [0, "not in the grid"]
    end
  else
    [0, "not an english word"]
  end
  end

  def included?(guess, grid)
  the_grid = @grid.clone.split
  guess.chars.each do |letter|
    the_grid.delete_at(the_grid.index(letter)) if the_grid.include?(letter.upcase)
  end
  grid.gsub(" ", "").size == guess.size + the_grid.size
  end


end

