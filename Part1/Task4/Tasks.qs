namespace QCHack.Task4 {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Diagnostics;

    // Task 4 (12 points). f(x) = 1 if the graph edge coloring is triangle-free
    // 
    // Inputs:
    //      1) The number of vertices in the graph "V" (V ≤ 6).
    //      2) An array of E tuples of integers "edges", representing the edges of the graph (0 ≤ E ≤ V(V-1)/2).
    //         Each tuple gives the indices of the start and the end vertices of the edge.
    //         The vertices are indexed 0 through V - 1.
    //         The graph is undirected, so the order of the start and the end vertices in the edge doesn't matter.
    //      3) An array of E qubits "colorsRegister" that encodes the color assignments of the edges.
    //         Each color will be 0 or 1 (stored in 1 qubit).
    //         The colors of edges in this array are given in the same order as the edges in the "edges" array.
    //      4) A qubit "target" in an arbitrary state.
    //
    // Goal: Implement a marking oracle for function f(x) = 1 if
    //       the coloring of the edges of the given graph described by this colors assignment is triangle-free, i.e.,
    //       no triangle of edges connecting 3 vertices has all three edges in the same color.
    //
    // Example: a graph with 3 vertices and 3 edges [(0, 1), (1, 2), (2, 0)] has one triangle.
    // The result of applying the operation to state (|001⟩ + |110⟩ + |111⟩)/√3 ⊗ |0⟩ 
    // will be 1/√3|001⟩ ⊗ |1⟩ + 1/√3|110⟩ ⊗ |1⟩ + 1/√3|111⟩ ⊗ |0⟩.
    // The first two terms describe triangle-free colorings, 
    // and the last term describes a coloring where all edges of the triangle have the same color.
    //
    // In this task you are not allowed to use quantum gates that use more qubits than the number of edges in the graph,
    // unless there are 3 or less edges in the graph. For example, if the graph has 4 edges, you can only use 4-qubit gates or less.
    // You are guaranteed that in tests that have 4 or more edges in the graph the number of triangles in the graph 
    // will be strictly less than the number of edges.
    //
    // Hint: Make use of helper functions and helper operations, and avoid trying to fit the complete
    //       implementation into a single operation - it's not impossible but make your code less readable.
    //       GraphColoring kata has an example of implementing oracles for a similar task.
    //
    // Hint: Remember that you can examine the inputs and the intermediary results of your computations
    //       using Message function for classical values and DumpMachine for quantum states.
    //
    operation Task4_TriangleFreeColoringOracle (
        V : Int, 
        edges : (Int, Int)[], 
        colorsRegister : Qubit[], 
        target : Qubit
    ) : Unit is Adj+Ctl {
        // Loop over all triplets of edges; if they form a triangle, we check the coloring using the Task3_ValidTriangle oracle
        let E = Length(edges);
        let counterRegisterSize = GetQubitRegisterSizeForNumberOfEdges(E);
        use counter = Qubit[counterRegisterSize];
        
        let counterLE = LittleEndian(counter); 

        if E>=3
        {
            within
            {
                for i in 0..E-1
                {
                    for j in i+1..E-1
                    {
                        for k in j+1..E-1
                        {
                            if (AreEdgesATriangle([edges[i], edges[j], edges[k]]))
                            {
                                use marker = Qubit()
                                {
                                    within
                                    {                            
                                        Task3_ValidTriangle([colorsRegister[i], colorsRegister[j], colorsRegister[k]], marker);
                                    }
                                    apply
                                    {
                                        Controlled IncrementCounter ([marker], (counterLE));
                                    }
                                }
                            }
                        }
                    }
                }
            }
            apply
            {
                use intermediaryQubits = Qubit[2]
                {
                    within
                    {
                        ControlledOnInt(0, X)(counterLE![0..1], intermediaryQubits[0]);
                        ControlledOnInt(0, X)(counterLE![2..counterRegisterSize-1], intermediaryQubits[1]);
                    }
                    apply
                    {
                        CCNOT(intermediaryQubits[0], intermediaryQubits[1], target);
                    }
                }
            }
        }
        else
        {
            X(target);
        }
    }

    function GetQubitRegisterSizeForNumberOfEdges(E: Int): Int{
        if E == 4
        {
            return 3;
        }
        return 4;
    }

    operation IncrementCounter(counter : LittleEndian) : Unit is Ctl+Adj
    {
        if (Length(counter!) >= 2)
        {
            Controlled IncrementCounter([counter![0]], LittleEndian(counter![1..Length(counter!)-1]));
        }
        X(counter![0]);
    }

    operation Task3_ValidTriangle (inputs : Qubit[], output : Qubit) : Unit is Adj+Ctl {
        within
        {
            CNOT(inputs[0], inputs[1]);
            CNOT(inputs[0], inputs[2]);
            X(inputs[1]);
            X(inputs[2]);
        }
        apply
        {
            CCNOT (inputs[1], inputs[2], output);
        }
    }

    // This function receives a list of 3 edges (tuples of integers) and checks if they form a triangle in the graph
    function AreEdgesATriangle(
        edgeTriplet : (Int, Int)[]
    ) : Bool
    {
        let firstVertex = FindCommonVertexForTwoEdges(edgeTriplet[0], edgeTriplet[1]);
        let secondVertex  = FindCommonVertexForTwoEdges(edgeTriplet[0], edgeTriplet[2]);
        let thirdVertex = FindCommonVertexForTwoEdges(edgeTriplet[1], edgeTriplet[2]);

        // if at least one pair of edges doesn't have a common vertex, this is not a triangle
        if (firstVertex == -1 or secondVertex == -1 or thirdVertex == -1)
        {
            return false;
        }

        // if one vertex is present in all 3 edges, this is not a triangle
        if (firstVertex == secondVertex or firstVertex == thirdVertex or secondVertex == thirdVertex)
        {
            return false;
        }
        return true;
    }

    // This function checks if 2 edges have a common vertex.
    // If they do, this function returns the common vertex index
    // If they don't, the function returns -1 (invalid vertex index)
    function FindCommonVertexForTwoEdges(
        firstEdge : (Int, Int), secondEdge : (Int, Int)
    ) : Int
    {
        if (Fst(firstEdge) == Fst(secondEdge))
        {
            return Fst(firstEdge);
        }
        if (Fst(firstEdge) == Snd(secondEdge))
        {
            return Fst(firstEdge);
        }
        if (Snd(firstEdge) == Fst(secondEdge))
        {
            return Snd(firstEdge);
        }
        if (Snd(firstEdge) == Snd(secondEdge))
        {
            return Snd(firstEdge);
        }
        return -1;
    }
}
