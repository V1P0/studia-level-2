import numpy as np
import random
import matplotlib.pyplot as plt
from typing import List, Set, Dict, Tuple


# --- Pre-computation and Constants ---

def harmonic(n: int) -> float:
    """Calculates the n-th harmonic number."""
    return sum(1 / i for i in range(1, n + 1))


def biharmonic(n: int) -> float:
    """Calculates the n-th biharmonic number."""
    return sum(1 / (i * i) for i in range(1, n + 1))


HARMONIC_TO_100: List[float] = [harmonic(i) for i in range(1, 101)]
BIHARMONIC_TO_100: List[float] = [biharmonic(i) for i in range(1, 101)]

# Note: In Python, lists are 0-indexed.
# HARMONIC_TO_100[63] corresponds to harmonic(64).
WEIGHTS: Dict[str, np.ndarray] = {
    'uniform': np.full(64, 1 / 64),
    'harmonic': np.array([1 / (i * HARMONIC_TO_100[63]) for i in range(1, 65)]),
    'biharmonic': np.array([1 / (i * i * BIHARMONIC_TO_100[63]) for i in range(1, 65)])
}


def generate_requests(weights_key: str, length: int = 65536) -> List[int]:
    """Generates a sequence of requests based on a given probability distribution."""
    # Vertex IDs are from 1 to 64
    vertices = np.arange(1, 65)
    return np.random.choice(vertices, size=length, p=WEIGHTS[weights_key]).tolist()


# --- Simulation Logic ---

class Vertex:
    """Represents a vertex in the graph."""

    def __init__(self, vertex_id: int):
        self.id: int = vertex_id
        self.state: int = 1
        self.counter: int = 0


def is_idle(copies: Set[int], states: List[Vertex]) -> bool:
    """Checks if the system is in an idle state."""
    # In an idle state, there is only one copy and its state is 4.
    # Vertex IDs are 1-based, list indices are 0-based.
    return len(copies) == 1 and states[list(copies)[0] - 1].state == 4


def count_allocation(
        requests: List[int],
        D: int,
        p: float,
        no_vertices: int = 64
) -> Tuple[int, int]:
    """
    Simulates the COUNT page allocation algorithm.
    """
    vertices: List[Vertex] = [Vertex(i) for i in range(1, no_vertices + 1)]
    copies: Set[int] = {1}  # Initially, the first vertex (ID 1) has the resource
    total_cost: int = 0
    max_copies: int = 1

    for req in requests:
        is_write = random.random() < p

        # --- Calculate request cost ---
        if is_write:
            total_cost += len(copies) - 1 if req in copies else len(copies)
        else:
            if req not in copies:
                total_cost += 1

        # --- Update vertex states based on the COUNT algorithm logic ---
        for v in vertices:
            is_req_vertex = (v.id == req)

            if v.state == 1:
                if v.counter >= D:
                    v.state = 2
                if is_req_vertex and (not is_write or is_idle(copies, vertices)):
                    v.counter += 1
            elif v.state == 2:
                if v.counter == D:
                    copies.add(v.id)
                    total_cost += D
                    v.state = 3
            elif v.state == 3:
                if v.counter > 0 and not is_req_vertex and is_write:
                    v.counter -= 1
                    if v.counter == 0:
                        v.state = 4
            elif v.state == 4:
                if not is_idle(copies, vertices):
                    v.state = 5
            elif v.state == 5:
                if v.id in copies:
                    copies.remove(v.id)
                v.state = 1

        max_copies = max(max_copies, len(copies))

    return total_cost, max_copies


# --- Experiment and Plotting ---

def run_experiments() -> Tuple[Dict, Dict]:
    """Runs the simulation for all combinations of D and p."""
    D_values = [16, 32, 64, 128, 256]
    P_values = [0.01, 0.02, 0.05, 0.1, 0.2, 0.5]
    RETRIES = 100

    result_costs = {d: {} for d in D_values}
    result_max_copies = {d: {} for d in D_values}

    for d in D_values:
        for p in P_values:
            total_cost_sum = 0.0
            max_copies_sum = 0.0
            print(f"Running experiments for D={d} and p={p}")
            for _ in range(RETRIES):
                requests = generate_requests('uniform')
                cost, max_c = count_allocation(requests, d, p)
                total_cost_sum += cost
                max_copies_sum += max_c

            result_costs[d][p] = total_cost_sum / RETRIES
            result_max_copies[d][p] = max_copies_sum / RETRIES

    return result_costs, result_max_copies


def plot_results(result_costs: Dict, result_max_copies: Dict) -> None:
    """Plots the results of the experiments."""
    D_values = list(result_costs.keys())
    P_values = list(next(iter(result_costs.values())).keys())

    # Plot 1: Average Costs
    plt.figure(figsize=(12, 6))
    for D in D_values:
        avg_costs = [result_costs[D][p] for p in P_values]
        plt.plot(P_values, avg_costs, marker='o', linestyle='-', label=f'D={D}')

    plt.title('Average Page Allocation Costs')
    plt.xlabel('Write Probability (p)')
    plt.ylabel('Average Cost')
    plt.legend(title='D values')
    plt.grid(True)
    plt.gca().get_yaxis().set_major_formatter(plt.FuncFormatter(lambda x, p: format(int(x), ',')))
    plt.tight_layout()
    plt.savefig('avg_costs.png')
    print("Saved average costs plot to avg_costs.png")

    # Plot 2: Average Maximum Copies
    plt.figure(figsize=(12, 6))
    for D in D_values:
        avg_max_copies = [result_max_copies[D][p] for p in P_values]
        plt.plot(P_values, avg_max_copies, marker='o', linestyle='-', label=f'D={D}')

    plt.title('Average Maximum Copies')
    plt.xlabel('Write Probability (p)')
    plt.ylabel('Average Max Copies')
    plt.legend(title='D values')
    plt.grid(True)
    plt.tight_layout()
    plt.savefig('avg_max_copies.png')
    print("Saved average maximum copies plot to avg_max_copies.png")


if __name__ == '__main__':
    # To run the script, uncomment the following lines:
    print("Starting simulation...")
    costs, max_copies = run_experiments()
    print("\nFinal Results (Costs):")
    print(costs)
    print("\nFinal Results (Max Copies):")
    print(max_copies)
    plot_results(costs, max_copies)
    print("\nScript finished.")
