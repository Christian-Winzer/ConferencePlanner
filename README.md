# ConferencePlanner
GAMS program to optimise conference schedule

Setup:
To run the program, put the following files in your GAMS working directory:
* CP_Algorithm.gms: the algorithm for optimising the conference schedule
* CP_Input.xlsx: the Excel file including the optimisation inputs: 
  - List of topics, 
  - List of participants, 
  - Votes of participants for topics, 
  - maximum number of time-slots and parallel sessions 

Execution:
Open and the CP_Algorithm in the GAMS-IDE and execute the code (F9).

Output:
The Algorithm creates a file called "CP_Output.xlsx" in your GAMS working directory, which contains:
* schedule: overview of topics (in columns) assigned to each slot (in rows)
* visits: overview of topics (in columns) suggested for each participant in each slot (in rows) based on his votes

