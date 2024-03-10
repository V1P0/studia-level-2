from collections import defaultdict

def compute_transition_function(pattern: str, alphabet: str) -> lambda q, a: int:
    m = len(pattern)
    delta = [defaultdict(int) for _ in range(m + 1)]
    for q in range(m + 1):
        for a in alphabet:
            k = min(m, q + 1)
            while not (pattern[:q] + a).endswith(pattern[:k]):
                k -= 1
            delta[q][a] = k
    return lambda q, a: delta[q][a]

def finite_automaton_matcher(text: str, delta: lambda q, a: int, m: int) -> list:
    q = 0
    n = len(text)
    for i in range(n):
        q = delta(q, text[i])
        if q == m:
            print(f"Pattern occurs with shift {i - m + 1}")

def main():
    pattern = "abc"
    text = "abcracabcdabra"
    alphabet = "abcdefghijklmnopqrstuvwxyz"
    delta = compute_transition_function(pattern, alphabet)
    finite_automaton_matcher(text, delta, len(pattern))

if __name__ == "__main__":
    main()