using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using static System.Diagnostics.Debug;

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

//
// This file will contain inputs for the demo
//

namespace MastermindQuantum
{
    static class Program
    {
        /// <summary>
        /// Main entry point.
        /// </summary>
        /// <param name="args">
        /// <para>Add the following argument to specify which puzzles to run:</para>
        /// <list type="bullet">
        /// <item><description>`all` or blank : run all puzzles (default)</description></item>
        /// <item><description>`4s4c` : test classic algorthm on a 4slot-4colors puzzle</description></item>
        /// <item><description>`4s4cQ` : test quantum algorthm on a 4slot-4colors puzzle</description></item>
        /// </list>
        /// </param>
        static async Task Main(string[] args)
        {
            using var sim = new QuantumSimulator();

            //var restored = await HelloQ.Run(sim);
            //DEBUG
            /*List<int[]> puzzle6 = new List<int[]>(){ 
                new int[]{0,3,1,2,1,1},
                new int[]{0,3,1,2,2,1},
                new int[]{0,3,1,2,3,1}
            };
            ShowGrid(puzzle6,1);
            Pause();*/

            //MAIN            
            var puzzleToRun = args.Length > 0 ? args[0] : "all";

            //var sim = new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: true);

            MastermindClassic mastermindClassic = new MastermindClassic();
            //MastermindQuantum mastermindQuantum = new MastermindQuantum();

            if (puzzleToRun == "4s4c" || puzzleToRun == "all") 
            {
                // Test solving a 4s4c Mastermind puzzle using classical computing
                long[] answer4 = { 1,2,3,0, 4,0 };
                long[] color4 = { 1,2,3,0 };
                bool resultFound = false;

                Console.WriteLine("Answer of current trial.");
                ShowGrid(new List<long[]>(){answer4}, 1);

                List<long[]> puzzle4 = new List<long[]>();
                Console.WriteLine("Solving 4slot-4colors using Classical computing.");
                resultFound = mastermindClassic.Solve(puzzle4, answer4);

                VerifyAndShowResult(resultFound, puzzle4, answer4);
                Console.WriteLine($"Classical Computing used {puzzle4.Count} trials !");
                Console.WriteLine();
            }
            if (puzzleToRun == "4s4cQ" || puzzleToRun == "all") 
            {
                // Test solving a 4s4c Mastermind puzzle using quantum computing.
                long[] answer4 = { 1,2,3,0, 4,0 };
                long[] color4 = { 1,2,3,0 };

                Console.WriteLine("Answer of current trial.");
                ShowGrid(new List<long[]>(){answer4}, 1);

                Console.WriteLine("Solving 4slot-4colors using Quantum computing.");

                var puzzleArray = new QArray<QArray<long>>();
                foreach (long[] condition in new List<long[]>(){answer4})
                {
                    puzzleArray.Append(new QArray<long>(condition));
                }
                var (resultFromQuantum, resultFound) = MastermindQuantum.GroversForMastermind.Run(sim, puzzleArray).Result;
                
                Console.WriteLine("Obtained result from Quantum simulator.");
                long[] answerFromQuantum = {-1, -1, -1 ,-1};
                int index = 0;
                foreach(long val in resultFromQuantum)
                {
                    answerFromQuantum[index] = val;
                    index++;
                }
                VerifyAndShowResult(resultFound, new List<long[]>(){answer4}, answerFromQuantum);
                Console.WriteLine();
            }
            
            if (puzzleToRun == "4s4cQ2" || puzzleToRun == "all") 
            {
                // Test solving a 4s4c Mastermind puzzle using quantum computing.
                List<long[]> answer4 = new List<long[]>();
                
                answer4.Add(new long[]{1, 1, 1, 2, 2, 10});
                answer4.Add(new long[]{1, 1, 2, 1, 2, 10});
                answer4.Add(new long[]{1, 2, 1, 1, 2, 10});

                long[] color4 = { 2, 1, 1, 1 };

                Console.WriteLine("Answer of current trial.");
                ShowGrid(answer4, 1);

                Console.WriteLine("Solving 4slot-4colors using Quantum computing.");

                var puzzleArray = new QArray<QArray<long>>();
                foreach (long[] condition in answer4)
                {
                    puzzleArray.Append(new QArray<long>(condition));
                }
                var (resultFromQuantum, resultFound) = MastermindQuantum.GroversForMastermind.Run(sim, puzzleArray).Result;
                
                Console.WriteLine("Obtained result from Quantum simulator.");
                long[] answerFromQuantum = {-1, -1, -1 ,-1};
                int index = 0;
                foreach(long val in resultFromQuantum)
                {
                    answerFromQuantum[index] = val;
                    index++;
                }
                VerifyAndShowResult(resultFound, answer4, answerFromQuantum);
                Console.WriteLine();
            }
            Console.WriteLine("Finished.");
        }

        
        /// <summary>
        /// If result was found, verify it is correct (matches the answer) and show it
        /// </summary>
        /// <param name="resultFound">True if a result was found for the puzzle</param>
        /// <param name="puzzle">The puzzle to verify</param>
        /// <param name="answer">The correct puzzle result</param>
        static void VerifyAndShowResult(bool resultFound, List<long[]> puzzle, long[] answer) 
        {
            if (!resultFound) 
                Console.WriteLine("No solution found.");
            else 
            {
                bool good = puzzle[puzzle.Count - 1].Cast<long>().SequenceEqual(answer.Cast<long>());
                if (good)
                    Console.WriteLine("Result verified correct.");
                ShowGrid(puzzle,1);
                Console.WriteLine("Answer from solver: ");
                ShowGrid(new List<long[]>{answer}, 0, false);
                
            }
            Pause();
        }

        /// <summary>
        /// Copy an Int 2 dimensional array
        /// </summary>
        /// <param name="org">The array to copy</param>
        /// <returns>A copy of the array</returns>
        static int[] CopyIntArray(int[] org)
        {
            int size = org.GetLength(0);
            int[] result = new int[size];
            for (int i = 0; i < size; i++)
                result[i] = org[i];
            return result;
        }

        /// <summary>
        /// Display the puzzle
        /// </summary>
        static void ShowGrid(List<long[]> puzzle, int withPegs = 0, bool withCounts = true)
        {
            char[] colorChar = {'R', 'G', 'B', 'Y', 'P', 'O'};
            char[] pegsChar = {'•', 'o'};
            int trials = puzzle.Count;
            int size = 0;
            if (withCounts)
            {  
                size = 6 + (withPegs>0?-2:0);
            }
            else
            {
                size = 4;
            }
            for (int i = 0; i < trials; i++)
            {
                Console.WriteLine(new String('-', 4 * size + 1));
                for (int j = 0; j < size; j++)
                {
                    Console.Write($"| {colorChar[puzzle[i][j]], 1} ");
                }
                Console.Write("|");
                
                if(withPegs>0){
                    for (int j = 0; j < puzzle[i][size]; j++)
                        Console.Write($"{pegsChar[0]}");
                    for (int j = 0; j < puzzle[i][size+1]; j++)
                        Console.Write($"{pegsChar[1]}");
                }
                Console.WriteLine();
            }
            Console.WriteLine(new String('-', 4 * size + 1));
        }

        /// <summary>
        /// Pause execution with a message and wait for a key to be pressed to continue.
        /// </summary>
        static void Pause()
        {
            System.Console.WriteLine("\n\nPress any key to continue...\n\n");
            System.Console.ReadKey();
        }
    }
}