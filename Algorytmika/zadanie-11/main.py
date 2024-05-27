import numpy as np

def monte_carlo_approximation(n_samples=100000):
    count = 0
    for _ in range(n_samples):
        x = np.random.uniform(0, np.pi)
        y = np.random.uniform(0, 1)

        if y <= np.sin(x):
            count += 1

    integral_approximation = (count / n_samples) * np.pi

    return integral_approximation

print(monte_carlo_approximation())