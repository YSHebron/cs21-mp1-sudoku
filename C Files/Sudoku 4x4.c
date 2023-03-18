#include <stdio.h>

#define N 4

int RowColCheck(int grid[], int row, int col, int test) {
    int j;
    // check row
    int rowpos = (row * 4);
    for (j = 0; j < 4; j++) {
        if (grid[rowpos + j] == test) {
            return 0;
        }
    }
    // check col
    for (j = col; j < 16; j += 4) {
        if (grid[j] == test) {
            return 0;
        }
    }
    return 1;
}

int BoxCheck(int grid[], int row, int col, int test) {
    int j;
    // check 2x2 square
    if (row <= 1 && col <= 1)
        j = 0;
    else if (row <= 1)
        j = 2;
    else if (row >= 2 && col <= 1)
        j = 8;
    else
        j = 10;

    int k = j + 1;
    for (; j <= k; j++) {
        if (grid[j] == test || grid[j + 4] == test) {
            return 0;
        }
    }
    return 1;
}

int sudoku(int grid[], int pos) {
    if (pos == 16) {
        return 1;
    }
    if (grid[pos] == 0) {
        int row = pos/4;            // get row from position
        int col = pos%4;            // get col from position, equiv to col = pos - row * 4
        // try test values
        for (int test = 1; test <= 4; test++) {
            // check validity of test value
            if (RowColCheck(grid, row, col, test) && BoxCheck(grid, row, col, test)) {
                // if all tests passed, insert, then recurse
                grid[pos] = test;
                if (sudoku(grid, pos + 1)) {
                    return 1;
                }
                grid[pos] = 0; // backtrack
            }
        }
    }
    else if (sudoku(grid, pos + 1)) {
        return 1;
    }
    return 0;
}

int main() {
    int grid[16] = {0};// grid with 16 positions, laid out as 1D array
    // utility function for getting grid
    int raw;
    for (int i = 0; i < 4; i++) {
        scanf("%d", &raw);
        for (int j = 3; j != -1; j--) {     // store must be done in reverse index to represent grid accurately
            int num = raw % 10;
            grid[j + (i * 4)] = num;
            raw = raw / 10;
        }
    }

    // solve grid, initialize solver at position 0 of grid
    sudoku(grid, 0);

    // utility function for printing
    for (int i = 0; i < 16; i++) {
        if (i % 4 == 0) {
            printf("\n");
        }
        printf("%d", grid[i]);
    }

    return 0;
}
