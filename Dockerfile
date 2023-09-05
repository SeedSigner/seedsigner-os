FROM debian:11

# buildroot dependencies
RUN apt-get -qq update
RUN apt-get -qq -y install \
locales=2.31-13+deb11u6 \
lsb-release=11.1.0 \
git=1:2.30.2-1+deb11u2 \
wget=1.21-1+deb11u1 \
make=4.3-4.1 \
binutils=2.35.2-2 \
gcc=4:10.2.1-1 \
g++=4:10.2.1-1 \
patch=2.7.6-7 \
gzip=1.10-4+deb11u1 \
bzip2=1.0.8-4 \
perl=5.32.1-4+deb11u2 \
tar=1.34+dfsg-1 \
cpio=2.13+dfsg-4 \
unzip=6.0-26+deb11u1 \
rsync=3.2.3-4+deb11u1 \
libmagic1=1:5.39-3 \
libmagic-mgc=1:5.39-3 \
file=1:5.39-3 \
bc=1.07.1-2+b2 \
libssl-dev=1.1.1n-0+deb11u5 \
vim=2:8.2.2434-3+deb11u1 \
build-essential=12.9 \ 
libncurses-dev=6.2+20201114-2+deb11u1 \
mtools=4.0.26-1 \
fdisk=2.36.1-8+deb11u1 \
dosfstools=4.2-1

# Locale
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf
RUN locale-gen en_US.UTF-8

WORKDIR /opt
ENTRYPOINT ["./build.sh"]
