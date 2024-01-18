@echo off
setlocal enabledelayedexpansion


REM Set the base URL for the series (replace with the one you want)
set "seriesURL=https://www.megacartoons.net/video-serie/spongebob-squarepants/"

REM Set the base URL
set "baseURL=https://ww.megacartoons.net"

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

        REM Replace &#8217; and &#8221; and &#8220; with nothing (add as needed )
        set "title=!title:&#8217;=!"
        set "title=!title:&#8221;=!"
        set "title=!title:&#8220;=!"

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

REM Prompt the user to choose a number
set /p "choice=Enter the number of the video to play: "

REM Check if the input is a number and within the valid range
if defined choice (
    set /a "choice=choice"
    if %choice% geq 1 if %choice% lss %counter% (
        REM Get the selected video link and title
        set "selectedVideoLink=!videoLinks[%choice%]!"
        set "selectedVideoTitle=!videoTitles[%choice%]!"

        REM Replace spaces with hyphens and remove periods in the title when constructing the URL
        set "selectedVideoTitleForURL=!selectedVideoTitle: =-!"
        set "selectedVideoTitleForURL=!selectedVideoTitleForURL:.=!"

        REM Construct the full video URL with .mp4 at the end
        set "selectedVideoURL=!baseURL!!selectedVideoLink!/video/SpongeBob-SquarePants-!selectedVideoTitleForURL!.mp4"

        REM Play the video using Windows Media Player in a separate process
        if defined selectedVideoURL (
            echo Playing video: !selectedVideoURL!
            start "" "wmplayer.exe" "!selectedVideoURL!"
        ) else (
            echo Invalid video link.
        )
    ) else (
        echo Invalid choice.
    )
)

REM Pause to keep the window open
pause
