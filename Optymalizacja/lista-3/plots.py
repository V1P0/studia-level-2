import pandas as pd
import matplotlib.pyplot as plt

def obj_func_plot():
    data = pd.read_csv('./results/obj.csv', names=['problem', 'optimal', 'actual'])
    plt.scatter(data['problem'], data['optimal'], label='optimal', color='blue', marker='o')
    plt.scatter(data['problem'], data['actual'], label='actual', color='red', marker='o')
    plt.xlabel('problem')
    plt.ylabel('value')
    plt.legend()
    plt.title('Objective Function')
    plt.savefig('./plots/plot.png')
    plt.clf()

    plt.scatter(data['problem'], data['actual']/data['optimal'], label='actual/optimal', color='green', marker='o')
    # line at y=1
    plt.axhline(y=1, color='black', linestyle='--')
    plt.xlabel('problem')
    plt.ylabel('value')
    plt.legend()
    plt.title('Objective Function Ratio')
    plt.savefig('./plots/plot_ratio.png')
    plt.clf()

def machine_t_plot(task, subtask):
    filename = f'./results/gap{task}-{subtask}.csv'
    data = pd.read_csv(filename, names=['Tmax', 'Tacc'])
    plt.scatter(range(len(data)), data['Tacc'], label='actual', color='red', marker='x')
    plt.scatter(range(len(data)), data['Tmax'], label='max', color='blue', marker='o')
    plt.scatter(range(len(data)), data['Tmax']*2, label='2*max', color='blue', marker='o')
    plt.xlabel('machine')
    plt.ylabel('time')
    plt.legend()
    plt.title(f'gap{task}-{subtask}')
    plt.savefig(f'./plots/plot_{task}-{subtask}.png')
    plt.clf()

if __name__ == '__main__':
    obj_func_plot()
    for task in range(1, 13):
        for subtask in range(1, 6):
            machine_t_plot(task, subtask)
