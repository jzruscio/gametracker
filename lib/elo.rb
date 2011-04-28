# Example:
# Elo.compute(1613, [ [ 1609, 0 ], [ 1477, 0.5 ], [ 1388, 1 ], [ 1586, 1 ], [ 1720, 0 ] ])

module Elo
  class <<self
    
    def compute(player_score=0, opponent_scores=[])
      # http://en.wikipedia.org/wiki/Elo_rating_system#Mathematical_details
      actual_score = opponent_scores.inject(0) do |sum, pair|
        sum += pair[1]
      end
      expected_score = opponent_scores.inject(0) do |sum, pair|
        sum += expected_score(player_score, pair[0])
      end
      player_score + k_value(player_score) * (actual_score - expected_score)
    end
  
    def expected_score(player_score, opponent_score)
      a = 10.0 ** (player_score / 400.0)
      b = 10.0 ** (opponent_score / 400.0)
      a / (a + b)
    end
  
    def k_value(player_score)
      # USCF K-Factor
      # http://en.wikipedia.org/wiki/Elo_rating_system#Most_accurate_K-factor
      if player_score < 2100
        32
      elsif player_score >= 2100 && player_score <= 2400
        24
      else
        16
      end
    end
  end
end