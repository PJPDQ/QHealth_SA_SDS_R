# QHealth Skill Assessment (AO6)

The following repository contains the solutions of the tasks provided by Queensland Health. The software is designed to meet the requirement for tidy-focused data cleaning, understanding trends in the data, communicate the output, understand query relational databases and demonstrate the fluency in git version control and basic sys-admin tasks.

# Quick Start

## Prerequistes
- **RStudio** 2026.01.1 Build 403 (Recommended)
- **R** 4.5.3

## Build 
```{bash}
git clone https://github.com/PJPDQ/QHealth_SA_SDS_R.git
cd output
```
To start R in project directory and restore the dependencies based on the available `renv.lock`
```{R}
install.packages("renv")
renv::restore()
```


### To run the solutions, you can find them in `.\R\solutions`
```{R}
source (".\R\solutions\TASK1.R")
source (".\R\solutions\TASK2.R")
```