namespace Quantum.Kata.Mastermind {
    
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Convert;

    
    @Test("QuantumSimulator")
    operation Task_1_1_SimpleTest () : Unit {
        // This code is based on the tests for Part 1 Task 3
        for registerLength in 2..5
        {
            for actualState in 0 .. 2^registerLength - 1 
            {
                for expectedState in 0..2^registerLength -1 
                {
                    use (inputs, output) = (Qubit[registerLength], Qubit());
                    within {
                        ApplyXorInPlace(actualState, LittleEndian(inputs));
                        AllowAtMostNCallsCA(0, Measure, "You are not allowed to use measurements");
                    } apply {
                        Task_1_1_CompareWithInteger(LittleEndian(inputs), expectedState, output);
                    }

                    // Check that the result is expected
                    let actual = ResultAsBool(MResetZ(output));
                    let expected = (actualState == expectedState);
                    Fact(actual == expected,
                        $"Oracle evaluation result {actual} does not match expected {expected} for assignment {actualState}, {expectedState}");

                    // Check that the inputs were not modified
                    Fact(MeasureInteger(LittleEndian(inputs)) == 0, 
                        $"The input states were modified for assignment for assignment {actualState}, {expectedState}");
                }
            }
        }
        
        Message("Task_1_1_SimpleTest passed.");
    }

    @Test("QuantumSimulator")
    operation Task_1_3_SimpleTest () : Unit {
        // This code is based on the tests for Part 1 Task 3
        for registerLength in 2..5
        {
            for actualState in 0 .. 2^registerLength - 1 
            {
                for expectedState in 0..2^registerLength -1 
                {
                    use (inputs, output) = (Qubit[registerLength], Qubit());
                    within {
                        ApplyXorInPlace(actualState, LittleEndian(inputs));
                        //AllowAtMostNCallsCA(0, Measure, "You are not allowed to use measurements");
                    } apply {
                        Task_1_3_CompareAndIncrement(expectedState, LittleEndian(inputs), LittleEndian([output]));
                    }

                    // Check that the result is expected
                    let actual = ResultAsBool(MResetZ(output));
                    let expected = (actualState == expectedState);
                    Fact(actual == expected,
                        $"Oracle evaluation result {actual} does not match expected {expected} for assignment {actualState}, {expectedState}");

                    // Check that the inputs were not modified
                    Fact(MeasureInteger(LittleEndian(inputs)) == 0, 
                        $"The input states were modified for assignment for assignment {actualState}, {expectedState}");
                }
            }
        }
        
        Message("Task_1_3_SimpleTest passed.");
    }

    @Test("QuantumSimulator")
    operation Task_1_6_SimpleTest () : Unit {
        use target = Qubit() 
        {
            use currentGuess = Qubit[8]
            {
                within
                {
                    X(currentGuess[0]);
                    X(currentGuess[2]);
                }
                apply
                {
                    let registers = Chunks(2, currentGuess);
                    let regLEs = Mapped(LittleEndian(_), registers);
                    Task_1_6_MastermindOracle(
                        regLEs,
                        [[1, 0, 1, 2, 1, 4]],
                        target
                    );
                }
                AssertMeasurement([PauliZ], [target], One, "Oracle replied with False when it should have said True.");
                Reset(target);
                ResetAll(currentGuess);
            }
        }
        
        Message("Task_1_6_SimpleTest passed.");
    }

    @Test("QuantumSimulator")
    operation Task_1_6_SimpleTest2 () : Unit {
        use target = Qubit() 
        {
            use currentGuess = Qubit[8]
            {
                let registers = Chunks(2, currentGuess);
                let regLEs = Mapped(LittleEndian(_), registers);

                // the current guess is prepared to be [0, 0, 0, 0],
                // which doesn't satisfy the guess [0, 0, 0, 0, 0, 0] (the current guess has 4 exact matches, the condition has 0 exact matches)
                Task_1_6_MastermindOracle(
                    regLEs,
                    [[0, 0, 0, 0, 0, 0]],
                    target
                );
                AssertMeasurement([PauliZ], [target], Zero, "Oracle replied with True when it should have said False.");
                Reset(target);
                ResetAll(currentGuess);
            }
        }
        
        Message("Task_1_6_SimpleTest2 passed.");
    }
}
