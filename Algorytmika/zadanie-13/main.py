import numpy as np

# Define the function
def f(x):
    return np.sqrt(1 - x**2)

# Stratified sampling
def stratified_sampling(n):
    strata = np.linspace(0, 1, n+1)  # Create strata
    u_strat = np.random.uniform(strata[:-1], strata[1:])  # Draw sample from each stratum
    return np.mean(f(u_strat))  # Compute the mean of the function values at the sample points

# Antithetic variates
def antithetic_variates(n):
    u = np.random.uniform(0, 1, n//2)  # Draw half the samples
    u_antithetic = 1 - u  # Create antithetic variates
    u_combined = np.concatenate((u, u_antithetic))  # Combine original and antithetic variates
    return np.mean(f(u_combined))  # Compute the mean of the function values at the sample points

# Test the methods
n = 10000
print("Stratified sampling estimate:", stratified_sampling(n))
print("Antithetic variates estimate:", antithetic_variates(n))