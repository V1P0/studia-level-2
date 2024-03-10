def horner_method(coefficients, x):
    result = 0
    for coefficient in coefficients[::-1]:
        result = result * x + coefficient
    return result


coeffs = [2, 1, 3, 7]  # 2x^3+x^2+3x+7
print(horner_method(coeffs, 5))
