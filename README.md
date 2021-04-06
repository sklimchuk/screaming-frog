# General

With Dockerfile from this repo you can build image and run container with latest [Screaming Frog](https://www.screamingfrog.co.uk/) 14.3.

# Contents

**Dockerfile** - Main part based on Ubuntu 20.04 LTS and software needed to install screamingfrogseospider_14.3_all.deb and use SFTP. 
Here we're preparing all needed folders and including configs as well.

**licence.txt** - SEO Spider Licence file, you can purchase license [here](https://www.screamingfrog.co.uk/seo-spider/licence/).

**01_nodoc** - config which prevent not needed documentaion/man pages/locales setup.
spider.config - unattended EULA agreement parameter with storage dir specification.

**.screamingfrogseospider** - JVM parameters can be tuned here.

**ssh_config** - disabling StrictHostKeyChecking to connect to different SFTP servers via lftp tool.

**run_crawler.sh** - script for a batch screaming frog export using a json file with a list of defined sites.
See [this manual](https://www.screamingfrog.co.uk/seo-spider/user-guide/general/) for more information regarding command line guide and UI interface.

**siteids.json** - input file for processing, here is an example of input:

```
[
    {
        "site_id": "PROJECT01",
        "site_url": "http:\/\/www.nooooooooooooooo.com"
    },
    {
        "site_id": "PROJECT02",
        "site_url": "https:\/\/guthib.com"
    }
]

```

# How it works

run_crawler.sh script connects to SFTP server, jump to import folder, grab siteids.json file, parse it to site_urls and site_ids arrays.
Then in for loop screamingfrogseospider tool in headless mode stated processing of your sites and saving reports in two files for each site (crawl_overview.csv and crawl.seospider). When all sites processed script uploaded all results to SFTP into export folder.

# How to use

Update your licence.txt with your licence (script will not work without it), then update run_crawler.sh with proper SFTP connection settings, see SFTP* variables.
After that you can rebuild image with command:
```
$ docker build -t your-tag .
```

And finally run container on top of your new image:
```
$ docker run -d your-tag
```

You can see processing log output with command:
```
$ docker logs --tail 1000 -f id-of-your-new-container
```
