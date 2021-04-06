FROM ubuntu:20.04
CMD ["/sbin/my_init"]

ARG  SF_DEB=screamingfrogseospider_14.3_all.deb
COPY 01_nodoc /etc/dpkg/dpkg.cfg.d/

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
    apt-get update && \
    apt-get -y install --no-install-recommends \
    dialog \
    apt-utils \
    ttf-mscorefonts-installer \
    xdg-utils \
    zenity \
    fonts-wqy-zenhei \
    libgconf-2-4 \
    libasound2 \
    libasound2-data \
    libgail-common \
    libgail18 \
    libgtk2.0-0 \
    libgtk2.0-bin \
    libgtk2.0-common \
    libnspr4 \
    libnss3 \
    libxss1 \
    curl \
    wget \
    jq \
    tmux \
    xvfb \
    lftp \
    ssh

RUN wget --progress=dot:giga https://download.screamingfrog.co.uk/products/seo-spider/$SF_DEB -O /tmp/$SF_DEB && \
    dpkg -i /tmp/$SF_DEB && \
    apt-get install -f -y && \
    rm /tmp/$SF_DEB && \
    mkdir -p /home/screamingfrog/export && \
    mkdir -p /home/screamingfrog/import && \
    mkdir /root/.ScreamingFrogSEOSpider

RUN apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -rf /usr/share/doc/* /usr/share/man/* /usr/share/locale/*  

COPY spider.config licence.txt /root/.ScreamingFrogSEOSpider/
COPY .screamingfrogseospider /root/
COPY ssh_config /root/.ssh/config
COPY run_crawler.sh /home/screamingfrog/

ENTRYPOINT ["bash", "/home/screamingfrog/run_crawler.sh"]
