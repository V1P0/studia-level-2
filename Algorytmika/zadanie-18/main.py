import random


def vitter(k):
    moments = []
    n = 0
    while len(moments) < k:
        n += 1
        num = random.random()
        if num <= 1/n:
            moments.append(n)
            print(len(moments))
            print(moments)

    return moments


print(vitter(20))