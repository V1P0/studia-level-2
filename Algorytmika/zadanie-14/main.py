
def derandomized_cut(G):
    # Sort vertices by degree
    vertices = sorted(G.nodes, key=G.degree, reverse=True)

    # Initialize empty subsets
    S1, S2 = set(), set()

    # Initialize counts of edges in each subset
    E1, E2 = 0, 0

    # Assign vertices to subsets
    for v in vertices:
        if E1 < E2:
            S1.add(v)
            E1 += G.degree(v)
        else:
            S2.add(v)
            E2 += G.degree(v)

    # Return the cut
    return S1, S2