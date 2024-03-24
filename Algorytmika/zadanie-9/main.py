def find_substrings(x):
    start_codon = 'ATG'
    stop_codons = ['TAA', 'TAG', 'TGA']
    substrings = []
    start = 0
    while start < len(x):
        if x[start:start+3] == start_codon:
            start += 3
            len_u = 0
            while start < len(x) and x[start:start+3] not in stop_codons:
                if x[start:start+3] == start_codon:
                    break
                start += 1
                len_u += 1
            if len_u >= 30:
                substrings.append(x[start-len_u-3:start+3])
        else:
            start += 1
    return substrings

b = "ATGCACGTCCAACAAACATCAAAACAAAAAAAATAACTTTGATAATGCACGGTCCACAAACTCAAGGCAACAAAAAACTGA"
#    ATG------------------------------TAA
#                                                  ATG-------------------------------TGA
print(find_substrings(b))

c = "ATGCCAAAAAAAAATGCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCTAA"
#    ATG------------x
#                 ATG-------------------------------TAA
print(find_substrings(c))

