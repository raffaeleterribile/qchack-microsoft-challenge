namespace QCHack.Task3 {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;

    // Task 3 (5 points). f(x) = 1 if at least two of three input bits are different - hard version
    //
    // Inputs:
    //      1) a 3-qubit array "inputs",
    //      2) a qubit "output".
    // Goal: Implement a marking oracle for function f(x) = 1 if at least two of the three bits of x are different.
    //       That is, if both inputs are in a basis state, flip the state of the output qubit 
    //       if and only if the three bits written in the array "inputs" have both 0 and 1 among them,
    //       and leave the state of the array "inputs" unchanged.
    //       The effect of the oracle on superposition states should be defined by its linearity.
    //       Don't use measurements; the implementation should use only X gates and its controlled variants.
    //       This task will be tested using ToffoliSimulator.
    // 
    // For example, the result of applying the operation to state (|001⟩ + |110⟩ + |111⟩)/√3 ⊗ |0⟩
    // will be 1/√3|001⟩ ⊗ |1⟩ + 1/√3|110⟩ ⊗ |1⟩ + 1/√3|111⟩ ⊗ |0⟩.
    //
    // In this task, unlike in task 2, you are not allowed to use 4-qubit gates, 
    // and you are allowed to use at most one 3-qubit gate.
    // Warning: some library operations, such as ApplyToEach, might count as multi-qubit gate,
    // even though they apply single-qubit gates to separate qubits. Make sure you run the test
    // on your solution to check that it passes before you submit the solution!
    operation Task3_ValidTriangle (inputs : Qubit[], output : Qubit) : Unit is Adj+Ctl {
        // All 3 bits are equal iff inputs[0]==inputs[1] and inputs[0]==inputs[2])
        // Two bits are equal iff their xor is 0; so the condition can be written as 
        //      inputs[0] xor inputs[1] == 0 and inputs[0] xor inputs[2] == 0
        // The xor of 2 qubits can be computed using CNOT
        // We will compute the 2 xor values, flip them, then use a CCNOT gate to check if both xnor values are 1
        // Since we need to flip the output qubit if the 3 bits are different (so the negation of what we computed), we apply a final X gate on the output

        within
        {
            CNOT(inputs[0], inputs[1]); // inputs[0] xor inputs[1]
            CNOT(inputs[0], inputs[2]); // inputs[0] xor inputs[2]
            X(inputs[1]); // inputs[0] xnor inputs[1]
            X(inputs[2]); // inputs[0] xnor inputs[2]
        }
        apply
        {
            CCNOT (inputs[1], inputs[2], output);  // flip output if (inputs[0] xnor inputs[1] == 1) and (inputs[0] xnor inputs[1] == 1)
            X(output); //  flip output if !((inputs[0] xnor inputs[1]) and (inputs[0] xnor inputs[1]) == 1) <==)
                       // (inputs[0] xor inputs[1] == 1 or inputs[0] xor inputs[2] ==1 )  <-==> (inputs[0] != inputs[1] or inputs[0] != inputs[2])
        }
    }
}

