namespace QCHack.Task1 {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Diagnostics;
    // Task 1 (1 point). f(x) = 1 if x is divisible by 4
    //         
    // Inputs:
    //      1) an N-qubit array "inputs" (3 ≤ N ≤ 5),
    //      2) a qubit "output".
    // Goal: Implement a marking oracle for function f(x) = 1 if x is divisible by 4.
    //       That is, if both inputs are in a basis state, flip the state of the output qubit 
    //       if and only if the number written in the array "inputs" is divisible by 4,
    //       and leave the state of the array "inputs" unchanged.
    //       The array "inputs" uses little-endian encoding, i.e., 
    //       the least significant bit of the integer is stored first.
    //       The effect of the oracle on superposition states should be defined by its linearity.
    //       Don't use measurements; the implementation should use only X gates and its controlled variants.
    //       This task will be tested using ToffoliSimulator.
    // 
    // Example: the result of applying the oracle to a state (|001⟩ + |100⟩ + |111⟩)/√3 ⊗ |0⟩
    // will be 1/√3|001⟩ ⊗ |1⟩ + 1/√3|100⟩ ⊗ |0⟩ + 1/√3|111⟩ ⊗ |0⟩.
    //

    newtype Literal = (Index: Int, Polarity: Bool);
    newtype Term = Literal[];
    internal function LiteralIndex(literal: Literal): Int{ return literal::Index; }
    internal function LiteralPolarity(literal: Literal): Bool{ return literal::Polarity; }

    internal operation ApplyTerm(term: Term, controls: LittleEndian, target: Qubit) : Unit is Adj+Ctl{
        let index = Mapped(LiteralIndex, term!);
        let polarity = Mapped(LiteralPolarity, term!);
        let controlRegister = Subarray(index, controls!);
        ApplyControlledOnBitString(polarity, X, controlRegister, target);
    }

    operation ApplyESOP(terms: Term[], controls: LittleEndian, target: Qubit): Unit is Adj+Ctl{
        for term in terms{
            ApplyTerm(term, controls, target);
        }
    }
    operation Task1_DivisibleByFour (inputs : Qubit[], output : Qubit) : Unit is Adj+Ctl {

        // FLIP IF |00XXX>
        let esop = [
            Term([Literal(0, false), Literal(1, false)])
        ];

        ApplyESOP(esop, LittleEndian(inputs), output);
    }
}
