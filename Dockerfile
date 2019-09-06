FROM centos:7

# Forked from https://github.com/giovtorres/docker-centos7-slurm

ARG SLURM_TAG=slurm-19-05-1-2
ARG SLURM_DIR=/opt/$SLURM_TAG

ENV PATH "$SLURM_DIR/sbin:$SLURM_DIR/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin"

# Install common YUM dependency packages
RUN set -ex \
 && yum makecache fast \
 && yum -y update \
 && yum -y install epel-release \
 && yum -y install \
        autoconf \
        bash-completion \
        bzip2 \
        bzip2-devel \
        file \
        gcc \
        gcc-c++ \
        gdbm-devel \
        git \
        glibc-devel \
        gmp-devel \
        libffi-devel \
        libGL-devel \
        libX11-devel \
        make \
        mariadb-server \
        mariadb-devel \
        munge \
        munge-devel \
        ncurses-devel \
        openssl-devel \
        openssl-libs \
        perl \
        pkconfig \
        psmisc \
        readline-devel \
        sqlite-devel \
        tcl-devel \
        tix-devel \
        tk \
        tk-devel \
        supervisor \
        wget \
        vim-enhanced \
        xz-devel \
        zlib-devel \
 && yum clean all \
 && rm -rf /var/cache/yum

# Compile, build and install Slurm from Git source
RUN set -ex \
 && git clone https://github.com/SchedMD/slurm.git \
 && pushd slurm \
 && git checkout tags/$SLURM_TAG \
 && mkdir -p $SLURM_DIR \
 && ./configure --enable-debug --enable-front-end --prefix=$SLURM_DIR --with-mysql_config=/usr/bin \
 && make install \
 && install -D -m644 etc/cgroup.conf.example $SLURM_DIR/etc/cgroup.conf.example \
 && install -D -m644 etc/slurm.conf.example $SLURM_DIR/etc/slurm.conf.example \
 && install -D -m644 etc/slurmdbd.conf.example $SLURM_DIR/etc/slurmdbd.conf.example \
 && install -D -m644 contribs/slurm_completion_help/slurm_completion.sh /etc/profile.d/slurm_completion.sh \
 && popd \
 && rm -rf slurm \
 && groupadd -r slurm  \
 && useradd -r -g slurm slurm \
 && mkdir /etc/sysconfig/slurm \
      /var/spool/slurmd \
      /var/run/slurmd \
      /var/lib/slurmd \
      /var/log/slurm \
 && chown slurm:root /var/spool/slurmd \
      /var/run/slurmd \
      /var/lib/slurmd \
      /var/log/slurm \
 && /sbin/create-munge-key

# Copy Slurm configuration files into the container
COPY files/slurm/slurm.conf $SLURM_DIR/etc/slurm.conf
COPY files/slurm/gres.conf $SLURM_DIR/etc/gres.conf
COPY files/slurm/slurmdbd.conf $SLURM_DIR/etc/slurmdbd.conf
COPY files/supervisord.conf /etc/

# Mark externally mounted volumes
VOLUME ["/var/lib/mysql", "/var/lib/slurmd", "/var/spool/slurmd", "/var/log/slurm"]

COPY docker-entrypoint.sh /docker-entrypoint.sh

# Add Tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

ENTRYPOINT ["/tini", "--", "/docker-entrypoint.sh"]
CMD ["/bin/bash"]
