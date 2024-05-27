import numpy as np
import pandas as pd

def approximate_count(n):
    # Step 1: Generate random numbers
    random_numbers = np.random.uniform(0, 1, n)
    
    # Step 2: Collect list L (it's just the list of random numbers)
    L = list(random_numbers)
    
    # Step 3: Sort list L
    L.sort()
    
    # Step 4 & 5: Apply the algorithm
    if n <= 400:
        return n
    else:
        return 399 / L[399]

# Experiment for n in the range 1 to 10000
n_values = range(1, 10001)
results = []

for n in n_values:
    estimated_n = approximate_count(n)
    results.append((n, estimated_n))

# Convert results to a DataFrame
results_df = pd.DataFrame(results, columns=['Actual n', 'Estimated n'])

# Calculate the error
results_df['Error'] = np.abs(results_df['Actual n'] - results_df['Estimated n'])

import matplotlib.pyplot as plt

# Plot the estimated vs actual values
plt.figure(figsize=(10, 6))
plt.plot(results_df['Actual n'], results_df['Estimated n'], label='Estimated n', color='blue')
plt.plot(results_df['Actual n'], results_df['Actual n'], label='Actual n', color='red', linestyle='dashed')
plt.xlabel('Actual n')
plt.ylabel('Estimated n')
plt.title('Estimated vs Actual Values of n')
plt.legend()
plt.grid(True)
plt.savefig("approximate_count.png")