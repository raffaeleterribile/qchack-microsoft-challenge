// this file should be structured like a kata; break the problem into small functions; we can also make a ReferenceImplementation.qs, like in the katas

namespace Quantum.Kata.Mastermind {
    
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;

    // Task 1.1: The Compare register to integer oracle
    // Inputs:
    //      1) qubits: the input register which needs to be checked, in an arbitrary state |x⟩
    //      2) integer: the integer to which the register is compared
    //      3) target: a qubit in an arbitrary state |y⟩ 
    // Goal: Transform state |x, y⟩ into state |x, y ⊕ f(x)⟩ (⊕ is addition modulo 2),
    //       i.e., flip the target state if x == integer
    //       Leave the query register in the same state it started in.
    operation Task_1_1_CompareWithInteger(
        qubits : LittleEndian,
        integer : Int,
        target : Qubit
    ) : Unit is Adj + Ctl
    {
        // ...
    }


    // Task 1.2: Oracle check if 2 qubit registers are equal
    // Inputs:
    //      1) register1: the first input register which needs to be compared, in an arbitrary state |x⟩
    //      2) register2: the second input register which needs to be compared, in an arbitrary state |y⟩
    //      3) target: a qubit in an arbitrary state |z⟩ 
    // Goal: Implement the function f(x, y) = 1, if x==y
    //                                      = 0, otherwise
    //       Transform state |x,y,z⟩ into state |x, y, z ⊕ f(x, y)⟩ (⊕ is addition modulo 2),
    //       i.e., flip the target state if x == y
    //       Leave the query register in the same state it started in.
    operation Task_1_2_CompareRegistersOracle(
        register1: LittleEndian,
        register2: LittleEndian,
        target: Qubit
    ) : Unit is Adj + Ctl
    {
        // ...
    }

    // Task 1.3: Check if a register is equal to an integer, and increment a counter if true
    // Inputs:
    //      1) integerToBeCounted: an integer in the range 0..2^n-1 (where n is the number of qubits)
    //      2) register: the input register which needs to be compared, in an arbitrary state |x⟩
    //      3) counter: a counter register
    // Goal: Increment the counter if register == |integerToBetcounted>
    //       Leave the query register in the same state it started in.
    operation Task_1_3_CompareAndIncrement(
        integerToBeCounted : Int,
        register: LittleEndian,
        counter: LittleEndian
    ) : Unit is Adj + Ctl
    {
        // ...
    }

    // Task 1.4: Count occurences of the state |integerToBeCounted> in a register array
    // Inputs:
    //      1) integerToBeCounted: an integer in the range 0..2^n-1 (where n is the number of qubits)
    //      2) registerArray: the input register array
    //      3) counter: a counter register
    // Goal: Increment the counter for each register in the state |integerToBeCounted> in the array
    //       Leave the query register in the same state it started in.
    operation Task_1_4_CountInArray(
        integerToBeCounted : Int,
        registerArray : LittleEndian[],
        counter: LittleEndian
    ) : Unit is Adj + Ctl
    {
        // ...
    }

    // 
    //  The Mastermind game
    //  The purpose of the game is to guess a secret array of 4 integers; The integers encode colors, the possible colors are 0, 1, 2, 3
    //  For each guess of the form [a, b, c, d], where a, b, c, d are colors, information is given about how close the guess is to the secret solution:
    //      - the number of exact matches, given as a number of black pegs
    //           For each position (from 0 to 3), the guessed color in that position is compared to the secret color; if the colors match, a black peg is added
    //      - the number of partial matches: the secret color is present in the guess, but at the wrong position
    //           For each position (from 0 to 3), if the guessed color doesn't match the secret color, then: for each occurence of the secret color in the guess, a 
    //              white peg is added
    //  Example:
    //  Secret: [1, 0, 1, 2]
    //  Guess: [1, 1, 0, 0]
    //  This guess receives 1 black peg (exact match in position 0), and 4 white pegs:
    //          - for position 1 we get 2 partial matches (there are 2 diferent "1" guesses in the guess array)
    //          - for position 2 we get 1 partial match (these is 1 "0" in the guess array)
    //          - for position 3 we get 1 partial match (these is 1 "0" in the guess array)
    //  Note that the rule for the white pegs is different from the actual game (I couldn't implement a reasonably efficient oracle for the actual game) 

    //
    //  With each guess made, more and more information about the secret is gained; We will use Grover's algorithm to find a candidate for the secret, which
    //  satisfies all previous guesses.
    //


    // Task 1.5: Implement the Mastermind Check oracle for one condition
    // Inputs:
    //      1) currentGuess: an array of 4 2-qubit registers
    //      2) conditionValues: a previouos guess which has to be satisfied by the current guess
    //                          it has the form [a, b, c, d, exactMatches, partialMatches], where - [a, b, c, d] was the previous guess (a, b, c, d are integers in the set {0, 1, 2, 3})
    //                                                                                            - exactMatches is the number of black pegs for the guess [a, b, c, d]
    //                                                                                            - partialMatches is the number of white pegs for the guess [a, b, c, d]
    //      3) target : a qubit in an arbitrary state |y>
    // Goal: Transform state |x, y⟩ into state |x, y ⊕ f(x)⟩ (⊕ is addition modulo 2),
    //       i.e., flip the target state if currentGuess matches the condition (it produces the same number of exact matches and partial matches as the previous guess)
    //       Leave the query register in the same state it started in.
    operation Task_1_5_MastermindCheckCondition(
        currentGuess: LittleEndian[],
        conditionValues : Int[],
        target: Qubit
    ) : Unit is Adj+ Ctl
    {
        // ...
    }

    // Task 1.6: Implement the Mastermind Check oracle for an array of conditions
    // Inputs:
    //      1) currentGuess: an array of 4 2-qubit registers
    //      2) conditionValues: an array of previous guesses which has to be satisfied by the current guess
    //                          it has the form [[a, b, c, d, exactMatches, partialMatches], ...], where - [a, b, c, d] was the previous guess (a, b, c, d are integers in the set {0, 1, 2, 3})
    //                                                                                            - exactMatches is the number of black pegs for the guess [a, b, c, d]
    //                                                                                            - partialMatches is the number of white pegs for the guess [a, b, c, d]
    //      3) target : a qubit in an arbitrary state |y>
    // Goal: Transform state |x, y⟩ into state |x, y ⊕ f(x)⟩ (⊕ is addition modulo 2),
    //       i.e., flip the target state if currentGuess matches the conditions (it produces the same numbers of matches for all the previous guesses)
    //       Leave the query register in the same state it started in.
    operation Task_1_6_MastermindOracle(
        currentGuess: LittleEndian[],
        conditions : Int[][],
        target: Qubit
    ) : Unit is Adj+ Ctl
    {
        // ...
    }

    operation Task_1_7_MastermindOracleNormalized(
        qubitArray : Qubit[],
        conditions : Int[][],
        target: Qubit
    ) : Unit is Adj+ Ctl
    {
        // ...
    }


    //////////////////////////////////////
    //This part, until the end if file is copied from or inspired by https://github.com/microsoft/QuantumKatas/blob/main/SolveSATWithGrover/ReferenceImplementation.qs
    //////////////////////////////////////
    operation OracleConverterImpl (markingOracle : ((Qubit[], Qubit) => Unit is Adj), register : Qubit[]) : Unit is Adj {
        use target = Qubit();
        within {
            // Put the target into the |-⟩ state, perform the apply functionality, then put back into |0⟩ so we can return it
            X(target);
            H(target);
        }
        apply {
            // Apply the marking oracle; since the target is in the |-⟩ state,
            // flipping the target if the register satisfies the oracle condition will apply a -1 factor to the state
            markingOracle(register, target);
        }
    }
    
    function OracleConverter (markingOracle : ((Qubit[], Qubit) => Unit is Adj)) : (Qubit[] => Unit is Adj) {
        return OracleConverterImpl(markingOracle, _);
    }

    operation GroversAlgorithm_Loop (register : Qubit[], oracle : ((Qubit[], Qubit) => Unit is Adj), iterations : Int) : Unit {
        let phaseOracle = OracleConverter(oracle);
        ApplyToEach(H, register);
        for i in 1 .. iterations {
            phaseOracle(register);
            within {
                ApplyToEachA(H, register);
                ApplyToEachA(X, register);
            }
            apply {
                Controlled Z(Most(register), Tail(register));
            }
        }
        DumpRegister("", register);
    }

    operation GroversForMastermind (
        conditions : Int[][]
        ) : (Int[], Bool)
    {
        mutable answer = new Bool[8];
        use (register, output) = (Qubit[8], Qubit());
        mutable correct = false;
        mutable iter = 1;
        let oracle = Task_1_7_MastermindOracleNormalized(_, conditions, _);
        repeat {
            Message($"Trying search with {iter} iterations");
            GroversAlgorithm_Loop(register, oracle, iter);
            let res = MultiM(register);
            // to check whether the result is correct, apply the oracle to the register plus ancilla after measurement
            oracle(register, output);
            if (MResetZ(output) == One) {
                Message($"Found a valid solution");
                set correct = true;
                set answer = ResultArrayAsBoolArray(res);
            }
            else
            {
                Message($"Found an invalid solution");
            }
            ResetAll(register);
            Reset(output);
        } until (correct or iter > 10000)  // the fail-safe to avoid going into an infinite loop
        fixup {
            set iter *= 2;
        }
        
        let answerRegisters = Chunks(2, answer);
        let answerInts = Mapped(BoolArrayAsInt(_), answerRegisters);
        return (answerInts, correct);
    }

}
