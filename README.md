# Oyster-Data-Requests
PROJECT DESCRIPTION:  <br>
This project is intended to house code for fulfilling data requests for FWRI oyster data. Data managers are currently the only FWRI staff who will be able to execute these queries.

PROJECT STATUS:  
This project is currently active. These files will be revised as needs arise. 

GETTING STARTED:  
You will need:
1. Microsoft SQL Server Management Studio (SSMS) 
2. Git
3. (Optional) GitHub Desktop or other GUI git tool

SUGGESTED WORKFLOW:
1. If you need to make changes, "Create an Issue" in GitHub describing what changes, additions, or issues need to be addressed.
2. Pull a current copy of this repo to your local machine.
3. Create a new branch to address the issue. Please use format: issue-#-Example when naming a new branch where # is the issue number and Example briefly describes the issue. Alternatively, on GitHub, on the Issues page: Development > Create a branch. 
4. Work on the issue in your local branch.
5. Commit changes to save your work.
6. If more time or contributions from others is needed, publish your branch back to the GitHub repo.
7. When the issue is resolved, issue a pull request to have the changes merged into the main branch and close the outstanding issue.
8. Once a branch is merged, delete that branch.

FILE STRUCTURE:  
Each request should be kept in its own folder. Folder naming should following the following conventions: <br>
YEAR_Month RequestingEntity DataBeingProvided <br><br>
Within each folder, please include the following: <br>
1. Correspondence of request as an Outlook item. It is helpful to include the request and your response so that future requests can be handled similarly.
2. SQL query or RMarkdown code that can be executed to fulfill response. It is up to the data manager's preference for what language to use for the request. You should use a single file to fulfill the request to make future, similar requests easy to duplicate
3. Request output. Typically, requests should be fulfilled with one or more Excel file. Use of tabs, joins, other file types, etc. are at the discretion of the data manager and the requestor.
4. Metadata. Each request should contain metadata providing information on each data field. This metadata can usually be found in the DataDictionary table. Placement of the metadata, whether in a tab in the request output or within the corresponce are at the discretion of the data manager.
