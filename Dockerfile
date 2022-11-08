FROM debian:stable

# buildroot dependencies
RUN apt-get -qq update
RUN apt-get -qq -y install \
locales \
lsb-release \
git \
wget \
make \
binutils \gcc \
g++ \
patch \
gzip \
bzip2 \
perl \
tar \
cpio \
unzip \
rsync \
file \
bc \
libssl-dev \
vim \
build-essential 

# Locale
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf
RUN locale-gen en_US.UTF-8

# RUN mkdir -p /data
# WORKDIR /data/build

ENTRYPOINT ["tail", "-f", "/dev/null"]

# Entry script - This will also run terminator
# COPY entrypoint.sh /usr/local/bin/
# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
