@echo off
setlocal enabledelayedexpansion

REM Set the base URL for the series (replace with the one you want)
set "seriesURL=https://www.megacartoons.net/video-serie/spongebob-squarepants/"

REM Set the base URL
set "baseURL=https://ww.megacartoons.net/video/SpongeBob-SquarePants-"

REM Set the number of pages to scrape (replace as needed)
set "numPages=14"

REM Initialize a counter for videos
set "counter=1"

REM Create arrays to store video links and titles
set "videoLinks=()"
set "videoTitles=()"

REM Loop through each page
for /L %%p in (1, 1, %numPages%) do (
    REM Set the URL to scrape for the current page
    set "url=!seriesURL!page/%%p/"
    
    REM Use curl to fetch the HTML content
    curl -s "!url!" > temp.html

    REM Find all occurrences of <h3 class="title">
    for /f "tokens=2 delims=<>" %%a in ('findstr /i "<h3 class=\"title\">" temp.html') do (
        REM Handle special characters within the title
        set "title=%%a"

        REM Remove <i class="icon-right"></i>
        set "title=!title:<i class="icon-right"></i> =!"

        REM Replace &#8217; and &#8221; and &#8220; with nothing (add as needed)
        set "title=!title:&#8217;=!"
        set "title=!title:&#8221;=!"
        set "title=!title:&#8220;=!"
        set "title=!title:&#x2665;=!"

        REM Extract the video link from the title
        for /f "tokens=2 delims=('" %%v in ('echo !title! ^| find /i "href="') do (
            set "videoLink=%%v"
        )

        REM Display the title with the counter and store it in the array
        echo !counter!. !title!
        set "videoTitles[!counter!]=!title!"

        REM Add the video link to the array
        set "videoLinks[!counter!]=!videoLink!"

        REM Increment the counter
        set /a "counter+=1"
    )

    REM Clean up temporary files for the current page
    del temp.html
)

:menu
REM Display the menu
echo.
echo 1. Play a specific video
echo 2. Play a random video
echo 3. Binge-watch all videos
echo 4. Exit

REM Prompt the user to enter their choice
set /p "menuChoice=Enter your choice: "

REM Process the user's choice
if "%menuChoice%"=="1" (
    call :playSpecificVideo
) else if "%menuChoice%"=="2" (
    call :playRandomVideo
) else if "%menuChoice%"=="3" (
    call :bingeWatch
) else if "%menuChoice%"=="4" (
    echo Exiting...
    goto :eof
) else (
    echo Invalid choice. Please try again.
    goto :menu
)

REM Pause to keep the window open
pause
goto :eof

:playSpecificVideo
REM Prompt the user to enter the number of the video to play
set /p "choice=Enter the number of the video to play: "
if not defined choice goto :eof

REM Check if the input is a number and within the valid range
set /a "choice=choice"
if %choice% geq 1 if %choice% lss %counter% (
    call :playVideo %choice%
) else (
    echo Invalid choice.
)
goto :eof

:playRandomVideo
REM Generate a random number between 1 and the total number of videos
set /a "randomChoice=!random! %% counter + 1"

REM Call the function to play the specific video using the random number
call :playVideo %randomChoice%
goto :eof

:bingeWatch
REM Loop through all videos and play each one
for /L %%i in (1, 1, %counter%) do (
    call :playVideo %%i
)

REM Pause to keep the window open
pause
goto :eof

:playVideo
REM Get the selected video link and title
set "selectedVideoLink=!videoLinks[%1]!"
set "selectedVideoTitle=!videoTitles[%1]!"

REM Replace spaces with hyphens and remove periods in the title when constructing the URL
set "selectedVideoTitleForURL=!selectedVideoTitle: =-!"
set "selectedVideoTitleForURL=!selectedVideoTitleForURL:.=!"

REM Construct the full video URL with .mp4 at the end, removing ? and ,
set "selectedVideoURL=!baseURL!!selectedVideoLink!!selectedVideoTitleForURL!.mp4"
set "selectedVideoURL=!selectedVideoURL:?=!"
set "selectedVideoURL=!selectedVideoURL:,=!"

REM Play the video using Windows Media Player in a separate process
if defined selectedVideoURL (
    echo Playing video: !selectedVideoURL!
    call :waitVideoCompletion "!selectedVideoURL!"
) else (
    echo Invalid video link.
)
goto :eof

:waitVideoCompletion
REM Use start command with wait option to wait for Windows Media Player to exit
start /wait wmplayer.exe "%~1"
echo Video playback complete.
goto :eof
