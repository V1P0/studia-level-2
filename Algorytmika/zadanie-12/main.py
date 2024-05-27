import random
import copy

def karger_min_cut(graph):
    while len(graph) > 2:
        v = random.choice(list(graph.keys()))
        w = random.choice(graph[v])
        contract(graph, v, w)
    return len(list(graph.values())[0])

def contract(graph, v, w):
    for node in graph[w]:
        if node != v:
            graph[v].append(node)
        graph[node].remove(w)
        if node != v:
            graph[node].append(v)
    del graph[w]

# Test the function with a simple graph
graph = {
    'a': ['b', 'c'],
    'b': ['a', 'd'],
    'c': ['a', 'd'],
    'd': ['b', 'c']
}

min_cut = karger_min_cut(copy.deepcopy(graph))
print(f"Minimum cut of the graph is {min_cut}")

graph = {
   'a': ['b', 'c'],
   'b': ['a', 'd'],
   'c': ['a', 'd'],
   'd': ['b', 'c', 'e'],
   'e': ['d']
}
min_cut = karger_min_cut(copy.deepcopy(graph))
print