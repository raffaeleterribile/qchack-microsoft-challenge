
#nullable enable

using System;
using System.Collections.Generic;
using System.Linq;

namespace MastermindQuantum{
    /// <summary>
    /// Classical code to solve a Mastermind puzzle
    /// </summary>
    class MastermindClassic{

        public class Outcome{
            public int White { get; set; }
            public int Black { get; set; }
        }

        public class Combination{
            public long[] row;
            public long this[int key]{
                get => row[key];
                set => row[key] = value;
            }
        }

        public static Outcome Check(Combination guess, Combination solution){
            int exact_matches = 0;
            int partial_matches = 0;
            for (int i = 0; i < 4; i++){
                if (guess[i] == solution[i]){
                    exact_matches+=1;
                    continue;
                }else{
                    for(int j = 0; j < 4; j++){
                        if(guess[j] == solution[i])
                            partial_matches+=1;
                    }
                }
            }
            return new Outcome{ Black = exact_matches, White = partial_matches };
        }

        public bool Solve(List<long[]> puzzle, long[] answer){
            // generate all possible outcome
            List<Outcome> outcomes = new List<Outcome>();
            for(int i = 0; i <= 16; i++)
                for(int j = 0; j <= 4; j++)
                    outcomes.Add(new Outcome{White = i, Black = j});

            // generate all combinations
            List<Combination> combinations = new List<Combination>();
            for(long i = 0; i < 4; i++)
            for(long j = 0; j < 4; j++)
            for(long k = 0; k < 4; k++)
            for(long l = 0; l < 4; l++){
                long[] c = new long[]{i, j, k, l, 4, 0};
                combinations.Add(new Combination(){ row = c });
            }

            Combination answerComb = new Combination(){ row = answer };

            while(true){
                // generate new guess
                int min = Int32.MaxValue;
                Combination minCombination = null;
                foreach (var guess in combinations){
                    int max = 0;
                    foreach (var outcome in outcomes){
                        var count = 0;
                        foreach (var solution in combinations){
                            if (Check(guess, solution) == outcome)
                                count++;
                        }
                        if (count > max)
                            max = count;
                    }
                    if (max < min){
                        min = max;
                        minCombination = guess;
                    }
                }

                // Try Guess
                Outcome result = Check(minCombination, answerComb);
                long[] currTrial = new long[]{
                    minCombination[0],
                    minCombination[1],
                    minCombination[2],
                    minCombination[3],
                    result.Black,
                    result.White
                };

                puzzle.Add(currTrial);
                combinations.Remove(minCombination);
                if(result.Black==4) break;
            }
            return true;
        }
    }
}