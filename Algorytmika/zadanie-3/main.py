def biggest_k(first_string, second_string):
    l = min(len(first_string), len(second_string))
    
    for i in range(l, 0, -1):
        if first_string[:i] == second_string[-i:]:
            return i
    return 0

x = "psikacz"
y = "mopsik"
print(biggest_k(x, y))
