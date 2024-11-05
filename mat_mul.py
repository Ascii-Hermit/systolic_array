def matrix_multiply(A, B):
    # Check if the number of columns in A is equal to the number of rows in B
    if len(A[0]) != len(B):
        return "Matrices cannot be multiplied"

    # Create a result matrix with dimensions (rows of A) x (columns of B)
    result = [[0 for _ in range(len(B[0]))] for _ in range(len(A))]
    print("Matrix A")
    for i in range(3):
        for j in range(4):
            print(A[i][j])
    print("Matrix B")
    for i in range(4):
        for j in range(3):
            print(B[i][j])
    # Perform matrix multiplication
    for i in range(len(A)):
        for j in range(len(B[0])):
            for k in range(len(B)):

                result[i][j] += A[i][k] * B[k][j]

    return result

# Example matrices
A = [
    [1, 2, 3, 4],
    [4, 5, 6, 4],
    [0, 9, 5, 4]
]

B = [
    [1, 8, 9],
    [9, 10, 11],
    [11, 12, 9],
    [11, 12, 9]
]

# Multiply matrices
result = matrix_multiply(A, B)

# Print the result
for row in result:
    print(row)
