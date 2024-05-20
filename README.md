
We started this adventure to work on a devops project when it was found we were deprecating a unlicensed add-in to a customer's source code.

Possible Uses:
- Determine Source code inter-dependency by searching for names of files and functions with their occurences.
- Replacing a specific piece of code such as authentication and deprecated syntax.

Output(s):
----------
CSV output file containing the filename, pattern found and the line numbers in each file of the pattern occurence.


How to Setup and Use:
---------------------
Requires PowerShell 5.x or higher.
This is a quick and dirty way of searching line by line through text files and locating specific text in an input file. e.g. searching for password or mggraph in source code is possible with this tool.
Modify the Patterns.txt file to adjust the patterns searched for in each document.
Follow the usage statements to pass in the correct parameters
- If testing, use the override section and take off comments
Execute SearchAllFilesforPatterns.ps1 [with parms]


Script and Functions are self documented.
e.g. get-help .\SearchAllFilesforPatterns.ps1





