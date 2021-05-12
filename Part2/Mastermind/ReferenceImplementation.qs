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
    operation Task_1_1_CompareWithInteger_Reference(
        qubits : LittleEndian,
        integer : Int,
        target : Qubit
    ) : Unit is Adj + Ctl
    {
        ControlledOnInt(integer, X)(qubits!, target);
    }


    // Task 1.2: Oracle check if 2 qubit registers are equal
    operation Task_1_2_CompareRegistersOracle_Reference(
        register1: LittleEndian,
        register2: LittleEndian,
        target: Qubit
    ) : Unit is Adj + Ctl
    {
        within {
            ApplyToEachCA(CNOT, Zipped(register1!, register2!));
        } apply {
            // if all XORs are 0, the bit strings are equal.
            ControlledOnInt(0, X)(register2!, target);
        }
    }

    // Task 1.3: Check if a register is equal to an integer, and increment a counter if true
    operation Task_1_3_CompareAndIncrement_Reference(
        integerToBeCounted : Int,
        register: LittleEndian,
        counter: LittleEndian
    ) : Unit is Adj + Ctl
    {
        ControlledOnInt(integerToBeCounted, IncrementByInteger(1, _))(register!, counter);
    }

    // Task 1.4: Count occurences of the state |integerToBeCounted> in a register array
    operation Task_1_4_CountInArray_Reference(
        integerToBeCounted : Int,
        registerArray : LittleEndian[],
        counter: LittleEndian
    ) : Unit is Adj + Ctl
    {
        let forEachOperation = Task_1_3_CompareAndIncrement_Reference(integerToBeCounted, _, counter);
        ApplyToEachCA(forEachOperation, registerArray);
    }

    //  The Mastermind game
    operation Task_1_5_MastermindCheckCondition_Reference(
        currentGuess: LittleEndian[],
        conditionValues : Int[],
        target: Qubit
    ) : Unit is Adj+ Ctl
    {
        let conditionColors = conditionValues[0..3];
        let expectedExactMatches = conditionValues[4];
        let expectedPartialMatches = conditionValues[5];
        use counters = Qubit[7]
        {
            within
            {
                let exactCounter = LittleEndian(counters[0..2]);
                let partialCounter = LittleEndian(counters[3..6]);

                let guessesLength = Length(currentGuess);
                for i in 0 .. guessesLength-1
                {
                    use checkEquality = Qubit()
                    {
                        within
                        {
                            Task_1_1_CompareWithInteger_Reference(currentGuess[i], conditionColors[i], checkEquality);
                        }
                        apply
                        {
                            // if it is an exact match, we count it
                            Controlled (IncrementByInteger(1, _))([checkEquality], exactCounter);

                            // if it is not an exact match, we count all occurences in the other registers
                            X(checkEquality);
                            Controlled (Task_1_4_CountInArray_Reference(conditionColors[i], currentGuess, _))([checkEquality], partialCounter);
                            X(checkEquality);
                        }
                    }
                }
            }
            apply
            {
                let exactCounter = LittleEndian(counters[0..2]);
                let partialCounter = LittleEndian(counters[3..6]);
                use checkConditionQbits = Qubit[2]
                {
                    within
                    {
                        Task_1_1_CompareWithInteger_Reference(exactCounter, expectedExactMatches, checkConditionQbits[0]);
                        Task_1_1_CompareWithInteger_Reference(partialCounter, expectedPartialMatches, checkConditionQbits[1]);
                    }
                    apply
                    {
                        Controlled X(checkConditionQbits, target);
                    }
                }
            }
        }
    }

    // Task 1.6: Implement the Mastermind Check oracle for an array of conditions
    operation Task_1_6_MastermindOracle_Reference(
        currentGuess: LittleEndian[],
        conditions : Int[][],
        target: Qubit
    ) : Unit is Adj+ Ctl
    {
        use conditionQbits = Qubit[Length(conditions)]
        {
            //let conditionQubitPairs = Zipped(conditions, conditionQbits);
            //ApplyToEachCA((Task_1_6_MastermindCheckCondition(currentGuess, Fst(_), Snd(_))), conditionQubitPairs);
            within
            {
                for i in 0..Length(conditions) - 1
                {
                    Task_1_5_MastermindCheckCondition_Reference(currentGuess, conditions[i], conditionQbits[i]);
                }
            }
            apply
            {
                Controlled X(conditionQbits, target);
            }
        }
    }

    operation Task_1_7_MastermindOracleNormalized_Reference(
        qubitArray : Qubit[],
        conditions : Int[][],
        target: Qubit
    ) : Unit is Adj+ Ctl
    {
        let registers = Chunks(2, qubitArray);
        let regLEs = Mapped(LittleEndian(_), registers);
        Task_1_6_MastermindOracle_Reference(regLEs, conditions, target);
    }


    //////////////////////////////////////
    //This part, until the end if file is copied from or inspired by https://github.com/microsoft/QuantumKatas/blob/main/SolveSATWithGrover/ReferenceImplementation.qs
    //////////////////////////////////////
    operation OracleConverterImpl_Reference (markingOracle : ((Qubit[], Qubit) => Unit is Adj), register : Qubit[]) : Unit is Adj {
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
    
    function OracleConverter_Reference (markingOracle : ((Qubit[], Qubit) => Unit is Adj)) : (Qubit[] => Unit is Adj) {
        return OracleConverterImpl_Reference(markingOracle, _);
    }

    operation GroversAlgorithm_Loop_Reference (register : Qubit[], oracle : ((Qubit[], Qubit) => Unit is Adj), iterations : Int) : Unit {
        let phaseOracle = OracleConverter_Reference(oracle);
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

    operation GroversForMastermind_Reference (
        conditions : Int[][]
        ) : (Int[], Bool)
    {
        mutable answer = new Bool[8];
        use (register, output) = (Qubit[8], Qubit());
        mutable correct = false;
        mutable iter = 1;
        let oracle = Task_1_7_MastermindOracleNormalized_Reference(_, conditions, _);
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
