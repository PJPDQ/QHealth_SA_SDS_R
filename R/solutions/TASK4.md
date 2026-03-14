Q1. A colleague runs git status and sees the following output:
They run git commit -m "update cleaning script" immediately. What happens?

_Respond_: The code will be committed but not pushed but the file `data/raw/new_file.csv` will remain available in the local machine.

Q2: You are on branch `feature/new-plot` and run git merge `main`. Git reports a merge conflict in the script `R/analysis.R`. What is the the right course of action?

_Respond_: The right course of action is to resolve the merge conflict, then start running/ re-run the program to ensure all codes are running as expected. Then execute `pull` request from the `main` branch and `push` once everything is working as expected.

Q3. You are one of three data scientists collaborating on an analytical pipeline in a shared GitHub repository. Describe the branching and pull request workflow you would follow to add a new feature (e.g. a new visualisation function in R/plots.R) without disrupting your colleagues’ work on main.

_Respond_: I tend to follow a git flow variatn branching model with different types:
- `main` the production ready branch where this shall contain only release-ready code.  All commits MUST be tagged with semantic version numbers.
- `develop`: The integration branch where feature branches shall merge into this branch. All code MUST pass CI verification before merge.
- `feature/*`: Feature development branches.  These branches shall be created from "develop" and merged back to "develop" upon completion.
- `bugfix/*`:  Bug fix branches.  These branches shall be created from `develop` and merged back to `develop` upon completion.
- `hotfix/*`: Critical fix branches.  These branches shall be created from `main` and merged to both `main` and `develop` upon completion.
- `release/*`: Release preparation branches.  These branches shall be created from `develop` and merged to `main` upon release.
- `spike/*`: To explore potential solutions. These branches shall be deleted after using it. In case we want to keep it, make it into one of the above branch types.

Within the workflow procedure, all data scientists shall folllow this workflow for feature development:
1. Create feature branch
2. Local Development: the scientist must run local verification before committing.
3. Commit changes: the scientist must use conventional commit messages.
4. Push and Create a pull request: The scientist must push branch and create a pull request where it is targeted the `develop` branch.
5. Address Review feeback: The scientist must address all review comments. If there exists a pipeline, it must be run automatically on each push.
6. Merge: Upon, approval, the pull request shall be merged to develop. The `feature` branch shall be deleted after merged.

Q4. A colleague has accidentally committed a file containing a database password (config/db_credentials.R) and pushed it to the remote main branch. Describe the steps you would take to remediate this situation.

_Respond_: Immediate response: I would immediate revoke the password at the provider level (e.g., database), create a new password database for provider and purge the old secret. Afterwards, introduce a `.gitignore` within the repository to always exclude files from `config/*` folder, provide training for future preventions and/ or introduce an automatic continuous integration and continuous development pipelines that will provide robust layers of protections following the coding standards and compliances.

Q5. A colleague runs ls -l and sees the following for a script file:
-rwxr-x--- 1 jsmith analysts 4096 Feb 10 09:32 run_pipeline.sh
Describe the permissions on this file?

_Respond_: The permission allows owner to read, write and execute, analysts group to only read and execute while others has no sort of permissions.

Q6.  A new analyst joins your team. They have attempted to run a script that lives in /our_team_server/shared/run_analysis.R and they receive a Permission denied error. Explain how you would go about diagnosing and solving the issue here.

_Respond_: I would first execute the `ls -a` to see the permission types, check the permission level of the new analyst if the person has any, request permission from the owner or if I am part of the group/ owner with permitted permission, execute `chmod +r /our_team_server/shared/run_analysis.R` to allow read permission to the new analyst. 