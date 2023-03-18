#include <stdio.h>

#define N 9
void print_grid(int grid[]);

int RowColCheck(int grid[], int i, int col, int test) {
    int j;
    // check row
    int rowpos = i - col;
    for (j = 0; j < 9; j++) {
        if (grid[rowpos + j] == test) {
            return 0;
        }
    }
    // check col
    for (j = col; j < 81; j += 9) {
        if (grid[j] == test) {
            return 0;
        }
    }
    return 1;
}

int BoxCheck(int grid[], int row, int col, int test) {
    int j;
    // check 3x3 square
    if (row < 6) {
        if (row < 3) {
            if (col < 6) {
                if (col < 3) {
                    j = 0;
                } else {
                    j = 3;
                }
            } else {
                j = 6;
            }
        } else {
            if (col < 6) {
                if (col < 3) {
                    j = 27;
                } else {
                    j = 30;
                }
            } else {
                j = 33;
            }
        }
    } else {
        if (col < 6) {
            if (col < 3) {
                j = 54;
            } else {
                j = 57;
            }
        } else {
            j = 60;
        }
    }

    for (int k = 0; k <= 2; k++, j+=9) {
        for (int l = 0; l <= 2; l++) {
            if (grid[j + l] == test) {
                return 0;
            }
        }
    }

    return 1;
}

int sudoku(int grid[]) {
    for (int i = 0; i < 81; i++) {
        if (grid[i] == 0) {
            int row = i/9;                // get row from i
            int col = i%9;                // get col from i
            // try test values
            for (int test = 1; test <= 9; test++) {
                // check validity of test value
                if (RowColCheck(grid, i, col, test) && BoxCheck(grid, row, col, test)) {
                    // if all tests passed, insert, then recurse
                    grid[i] = test;
                    //print_grid(grid);
                    if (sudoku(grid)) {
                        return 1;
                    }
                    grid[i] = 0; // backtrack
                    //print_grid(grid);
                }
            }
            return 0;
        }
    }
    return 1;
}

int main() {
    int grid[81] = {0};            // grid with 81 positions, laid out as 1D array
    // get grid
    int raw;
    for (int i = 0; i < 81; i += 9) {
        scanf("%d", &raw);
        for (int j = 8; j != -1; j--) {     // store must be done in reverse index to represent grid accurately
            int num = raw % 10;
            grid[i + j] = num;
            raw = raw / 10;
        }
    }

    // solve grid, initialize solver at position 0 of grid
    sudoku(grid);

    // utility function for printing
    print_grid(grid);
    return 0;
}


void print_grid(int grid[]) {
    for (int i = 0; i < 81; i++) {
        if (i % 9 == 0) {
            printf("\n");
        }
        printf("%d", grid[i]);
    }
    printf("\n");
}