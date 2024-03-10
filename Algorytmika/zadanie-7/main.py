def rabin_karp(pattern, text):
    pattern_len = len(pattern)
    text_len = len(text)
    pattern_hash = hash(pattern)
    text_hash = hash(text[:pattern_len])

    for i in range(text_len - pattern_len + 1):
        if pattern_hash == text_hash and pattern == text[i:i+pattern_len]:
            return i
        if i < text_len - pattern_len:
            text_hash = (text_hash - ord(text[i])) // 2 + ord(text[i+pattern_len]) // 2

    return -1

def main():
    pattern = "abc"
    text = "abracadabra"
    result = rabin_karp(pattern, text)
    if result == -1:
        print("Pattern not found in text")
    else:
        print(f"Pattern found at index {result}")

if __name__ == "__main__":
    main()
