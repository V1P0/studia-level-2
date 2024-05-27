class Graph:
    def __init__(self, vertices):
        self.V = vertices
        self.graph = {}

    def add_edge(self, u, v):
        if u not in self.graph:
            self.graph[u] = []
        if v not in self.graph:
            self.graph[v] = []
        self.graph[u].append(v)
        self.graph[v].append(u)

    def derandomize_cut(self):
        S = set()
        T = set(self.graph.keys())
        expected_value = {}

        # Calculate expected values
        for v in self.graph:
            expected_value[v] = len(self.graph[v]) / 2

        # Derandomize - assign vertices to sets
        for v in self.graph:
            sum_incident_S = sum(1 for neighbor in self.graph[v] if neighbor in S)
            if sum_incident_S < expected_value[v]:
                S.add(v)
                T.remove(v)
            else:
                T.add(v)
                S.discard(v)

        return S, T

# Example usage
graph = Graph(6)
graph.add_edge(0, 1)
graph.add_edge(0, 2)
graph.add_edge(1, 2)
graph.add_edge(1, 3)
graph.add_edge(2, 4)
graph.add_edge(3, 4)
graph.add_edge(3, 5)

S, T = graph.derandomize_cut()
print("Set S:", S)
print("Set T:", T)
