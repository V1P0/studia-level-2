def lcs_of_3(X, Y, Z):
    m, n, o = len(X), len(Y), len(Z)
    L = [[['' for _ in range(o+1)] for _ in range(n+1)] for _ in range(m+1)]
    
    for i in range(1, m+1):
        for j in range(1, n+1):
            for k in range(1, o+1):
                if X[i-1] == Y[j-1] == Z[k-1]:
                    L[i][j][k] = L[i-1][j-1][k-1] + X[i-1]
                else:
                    L[i][j][k] = max(L[i-1][j][k], L[i][j-1][k], L[i][j][k-1], key=len)
    
    return L[m][n][o]


import unittest

class TestLCS(unittest.TestCase):
    def test_lcs_of_3(self):
        self.assertEqual(lcs_of_3('abc', 'abc', 'abc'), 'abc')
        self.assertEqual(lcs_of_3('abc', 'def', 'ghi'), '')
        self.assertEqual(lcs_of_3('abc', 'abc', 'acd'), 'ac')
        self.assertEqual(lcs_of_3('123456', '234567', '345678'), '3456')
        self.assertEqual(lcs_of_3('', '', ''), '')

if __name__ == '__main__':
    unittest.main()