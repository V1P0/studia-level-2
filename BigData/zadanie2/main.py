import numpy as np
import matplotlib.pyplot as plt
from scipy.special import gamma

def sphere_volume(n, r):
    return (np.pi ** (n / 2) * r ** n) / gamma(n / 2 + 1)

n_values = np.arange(1, 51)

radii = [0.5, 1, 2]

def main():
    plt.figure(figsize=(12, 8))

    for r in radii:
        volumes = sphere_volume(n_values, r)
        plt.plot(n_values, volumes, label=f'Promien r = {r}')

    plt.title('Objętosc n-wymiarowej kuli o promieniu r')
    plt.xlabel('Wymiar przestrzeni n')
    plt.ylabel('Objętość Vₙ(r)')
    plt.yscale('log')
    plt.legend()
    plt.grid(True)
    plt.savefig('sphere_volume.png')

if __name__ == '__main__':
    main()