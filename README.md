# **CS 21 Machine Problem 1: Sudoku**

## MIPS32 ASM 4x4 and 9x9 Sudoku Solver
We first took note of Sudoku's goal conditions and constraints.\
We then wrote C programs as basis (see `"C Files\"`), which we then converted to Assembly.\
Key to our approach are **backtracking** and **search space optimization**.\
Full documentation and Assembly files for the `4x4solver.asm` and `9x9solver.asm` sudoku solvers can be found in `"For Submission\"`.
### **Requirements**
- Windows XP or higher.
- Java Runtime Environment (JRE), Java 9 or higher. Latest Java SE recommended. Download: https://www.oracle.com/java/technologies/javase-downloads.html
- MARS v4.5. A Java program for teaching, compiling, and running MIPS32 Assembly. Download: http://courses.missouristate.edu/kenvollmar/mars/download.htm

Note: There is already a packaged `mars.jar` file in `"For Submission\"`.

### **Running the Program**
The sudoku solvers can be run in two ways.

1. **Through the MARS GUI.** In the menu bar, click File>Open, then navigate to the sudoku solver assembly files. Afterwards, in the toolbar, click Assemble (tool and wrench icon) then click Run (play icon). In the lower left, the execution pane will be visible through which you can paste test cases such as those found in the included 4x4.txt and 9x9.txt files in `"For Submission\`. Note that inputting test cases through the MARS GUI can only be done line-by-line.
2. **Through cmd.** Open your command line, `cd` to `"For Submission"` (where `mars.jar` already exists), then run `java -jar mars.jar <file_name>`. File name could be `4x4sovler.asm` or `9x9solver.asm`. You may now input your valid test cases to the cmd. 
### **Sample I/O**
For the 4x4 solver, an input test case is formatted as:
```
1000
0001
0400
0020
```

Which outputs:
```
1342
4231
2413
3124
```

For the 9x9 solver:
```
005800009
210000050
070900600
000201035
000000000
780405000
004006020
030000061
600003500
```
Which outputs:
```
465812379
219367458
378954612
946271835
523698147
781435296
154786923
832549761
697123584
```
---
Yenzy Urson S. Hebron

University of the Philippines Diliman

2nd Semester A.Y. 2021-2022