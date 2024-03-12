def rabin_karp(text, pattern, d, q):
    n = len(text)
    m = len(pattern)
    h = pow(d, m-1) % q
    p = 0
    t = 0
    result = []

    for i in range(m):
        p = (d*p + ord(pattern[i])) % q
        t = (d*t + ord(text[i])) % q

    for s in range(n-m+1):
        if p == t: 
            match = True
            for i in range(m):
                if pattern[i] != text[s+i]:
                    match = False
                    break
            if match:
                result = result + [s]

        if s < n-m:
            t = (t-h*ord(text[s])) % q #
            t = (t*d + ord(text[s+m])) % q 
            t = (t+q) % q

    return result

def main():
    pattern = "abc"
    text = "abcracadabcra"
    d = 256  # Assuming the input is ASCII characters
    q = 1000000007  # A large prime number
    result = rabin_karp(text, pattern, d, q)
    if not result:
        print("Pattern not found in text")
    else:
        for index in result:
            print(f"Pattern found at index {index}")


if __name__ == "__main__":
    main()
