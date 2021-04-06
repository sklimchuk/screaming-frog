#!/bin/bash

EnablingDisplay() {
  echo 'DISPLAY=":99"' >> /etc/environment
  source /etc/environment
  /usr/bin/Xvfb :99 -screen 0 1280x1024x24 -ac +extension GLX +render -noreset -nolisten tcp &
}


DownloadSFTP() {
  IMPORT_DIR=$1/import

  echo -e "[Begin]: Download files from SFTP $SFTPHOST to $IMPORT_DIR"	
  lftp sftp://$SFTPUSER:$SFTPPASSWD@$SFTPHOST:$SFTPPORT <<SCRIPT
    lcd ${IMPORT_DIR}
    cd import
    glob -d mirror
    bye
SCRIPT

  if [ $? -eq 0 ]; then
        echo -e "[End]: Files downloaded successfully"
  else
        echo -e "[Error]: Download file failed"
        exit 1
  fi
}


UploadSFTP() {
  EXPORT_DIR=$1/export

  echo -e "[Begin]: Upload files to SFTP $SFTPHOST from $EXPORT_DIR"	
  lftp sftp://$SFTPUSER:$SFTPPASSWD@$SFTPHOST:$SFTPPORT <<SCRIPT
    lcd ${EXPORT_DIR}
    cd export
    mirror -cv -R
    bye
SCRIPT

  if [ $? -eq 0 ]; then
        echo -e "[End]: Files uploaded successfully"
  else
        echo -e "[Error]: Upload file failed"
        exit 1
  fi
}

# Starting Xvfb service
EnablingDisplay

SFTPHOST="127.0.0.1"
SFTPPORT="2222"
SFTPUSER="user"
SFTPPASSWD="pass"
PROJECT_DIR="/home/screamingfrog"
# Importing siteids.json from SFTP for further processing
DownloadSFTP $PROJECT_DIR

# Set a default input folder with sites IDs
input_folder="$PROJECT_DIR/import";

# Set a default output folder for crawl SEO export
output_folder="$PROJECT_DIR/export";

# Get site urls as array;
site_urls=($(jq -r '.[].site_url' $input_folder/siteids.json));

# Get site ids as array;
site_ids=($(jq -r '.[].site_id' $input_folder/siteids.json));

index=0;
for site_id in "${site_ids[@]}"; do
  # Get site url from the list using same associtated to site id
  site_url=${site_urls[$index]};
  
  date=$(date +%Y%m%d);
    
  # Run the headless command
  mkdir -p $output_folder/$site_id-$date
  screamingfrogseospider --headless --crawl $site_url --save-crawl --output-folder $output_folder/$site_id-$date --export-format csv --save-report 'Crawl Overview'

  let index=${index}+1;
done

# Exporting processing results to SFTP
UploadSFTP $PROJECT_DIR