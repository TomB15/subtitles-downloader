#!/bin/bash
# ------------------------------ FUNCTIONS ---------------------------------

function fetchImdbId {
	url_fi="$1"

	res=`curl -s $url_fi`

	ec=$?
	if (( $ec > 0)) ; 
		then 
			echoerr "error -exited with codeL ${ec}"
			echo "Error - exited with code: " $ec 
			set -e
			exit 1
	fi

	if [ -z "$res" ];
	then
		echoerr "Nothing returned"
		exit 1
	elif [[ $(jq '.["Response"]' <<< $res) = *False* ]];
	then
		echoerr `jq '.["Error"]' <<< $res`
		exit 1
	fi

	imdb_id=`jq '.imdbID' <<< $res | tr -d '"'`
}

function prepareMovieName {
	desired_movie=$1

	movie_in_lower_case=`echo $desired_movie | sed 's/./\L&/g'`
	movie="${movie_in_lower_case// /+}" 
}

function fetchOpenSubtitlesResponse {
	os_url="$1"
	imdb_id="$2"
	selected_language="$3"

	os_url_fin=$os_url"imdbid-"$imdb_id"/sublanguageid-"${selected_language}


	open_subtitles_response=$(wget -qO- "${os_url_fin}")
}

function printSubtitlesNames {
	open_subtitles_response="$1"

	i=0
	while read LINE;
	do
		name=`jq '.["SubFileName"]' <<< $LINE | tr -d '"'`
		names[$i]=$name
		#echo "${names[${i}]}"
		i=$((i+1))
	done < <(jq -c '.[]'<<< $open_subtitles_response)

	i=0
	for name in "${names[@]}" 
	do
		echo "${i} - ${name}"
		i=$(($i+1))
	done
}

function createDownloadsDirectory {
	mkdir -p downloads
}

function downloadSubtitles {
	open_subtitles_response="$1"
	selected_subtitles_no="$2"
	save_dir="$3"

	default_new_file_name="downloaded_subtitles"

	subtitles_url=`jq '.['$selected_subtitles_no']["SubDownloadLink"]' <<< $open_subtitles_response | tr -d '"'`
	subtitles_name=`jq '.['$selected_subtitles_no']["SubFileName"]' <<< $open_subtitles_response | tr -d "'" | tr -d '"'`

	wget -qc $subtitles_url -O $save_dir$default_new_file_name.gz
	gunzip $save_dir$default_new_file_name.gz 
}

function renameDownloadedFile {
	subtitles_name="$1"
	save_dir="$2"
	default_new_file_name="$3"

	old_name=$save_dir$default_new_file_name
	new_name=$save_dir$subtitles_name
	mv "${old_name}" "${new_name}" 
}

function echoerr(){
	echo  "$@" 1>&2;
}
