#!/bin/bash  

source ./lib.sh
source ./config.sh

echo "============= SUBTITLES DOWNLOADER =============="
echo "Subtitles downloader helps you to download subtitles from https://www.opensubtitles.org"
echo "What movie?"

read desired_movie

prepareMovieName "$desired_movie"

url_fi=$imdb_url$movie 
fetchImdbId $url_fi 

fetchOpenSubtitlesResponse $os_url $imdb_id $language 

echo "-------- SUBTITLES --------"
printSubtitlesNames "$open_subtitles_response"

echo ""
echo "SELECT SUBTITLES NUMBER"
read selected_subtitles_no
echo "Selected: " $selected_subtitles_no

createDownloadsDirectory
downloadSubtitles "$open_subtitles_response" "$selected_subtitles_no" "$save_dir" 
renameDownloadedFile "$subtitles_name" "$save_dir" "$default_new_file_name"
echo "Subtitles was downloaded."

exit 0
