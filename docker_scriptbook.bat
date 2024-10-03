@echo off
REM Ensure the SCRIPTBOOK environment variable is set before running the script
REM SCRIPTBOOK should be set to the folder, where Dockerfile, docker-compose.yml and .env are located
if "%SCRIPTBOOK%"=="" (
    echo ERROR: SCRIPTBOOK environment variable is not set.
    exit /b 1
)

REM Check if a port number is provided as the first argument
if "%~1"=="" (
    set "port=7171"
) else (
    set "port=%~1"
)

REM Execute the Docker Compose command with the specified or default port
REM --file is used to provide path to docker configuration file
REM --project-directory is used to set working directory to the directory, from where script was started
REM     it used to store script's output files in the current folder
REM --env-file is used to specify .env file, which holds some configurations, used in docker-compose.yml (e.g. .config folder for tools)
docker-compose --file "%SCRIPTBOOK%\docker-compose.yml" --project-directory "%cd%" --env-file "%SCRIPTBOOK%\.env" run -p %port%:7171 --rm app

REM having this script I'm not really sure that docker-compose provides some useful abstractioning