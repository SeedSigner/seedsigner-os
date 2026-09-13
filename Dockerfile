FROM debian:12

# buildroot dependencies
RUN apt-get -qq update
RUN apt-get -y install \
locales \
lsb-release \
git \
wget \
make \
binutils \
gcc \
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
build-essential \
libncurses-dev \
mtools \
fdisk \
dosfstools \
ccache \
python3

# uv (build host only): creates the hash-verified translation venv from the app repo's
# uv.lock in build.sh. Pinned by version and image digest. Never installed into the
# target image.
COPY --from=ghcr.io/astral-sh/uv:0.12.13@sha256:b485bd65cc2cf1c9a93b3554012c9c3778cf7b1b5fd3d3096ce9e1226c97e1e6 /uv /usr/local/bin/uv
# Never download a managed CPython in the container (always use Debian's python3), and
# copy from the uv cache instead of hardlinking: /opt is a bind mount on another filesystem.
ENV UV_PYTHON_DOWNLOADS=never
ENV UV_LINK_MODE=copy

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
