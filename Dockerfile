FROM centos:7

LABEL maintener="myself"

ARG BUILD_DATE
ARG SLURM_VERSION

LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="slurm/"$SLURM_VERSION
LABEL org.label-schema.description="Slurm POC container w/Centos 7"
LABEL org.label-schema.version=$SLURM_VERSION
LABEL org.label-schema.docker.cmd="docker-compose up -d"

RUN echo -e "[mariadb]\n\
name = MariaDB\n\
baseurl = https://archive.mariadb.org/mariadb-10.6/yum/centos7-amd64/\n\
gpgkey=https://archive.mariadb.org/PublicKey\n\
gpgcheck=1\
" > /etc/yum.repos.d/mariadb.repo

RUN set -ex \
    && yum makecache fast \
    && yum -y update \
    && yum -y install epel-release \
    && yum -y install \
       wget \
       bzip2 \
       perl \
       gcc \
       gcc-c++\
       git \
       gnupg \
       make \
       munge \
       munge-devel \
       python-devel \
       python-pip \
       python34 \
       python34-devel \
       python34-pip \
       psmisc \
       bash-completion \
       supervisor \
       MariaDB-client \
       MariaDB-devel \
       vim-enhanced \
    && yum clean all \
    && rm -rf /var/cache/yum

RUN ln -s /usr/bin/python3.4 /usr/bin/python3

RUN pip install Cython nose && pip3.4 install Cython nose

RUN set -x \
    && git clone https://github.com/SchedMD/slurm.git \
    && pushd slurm \
    && git checkout tags/${SLURM_VERSION} \
    && ./configure --enable-debug --prefix=/usr --sysconfdir=/etc/slurm \
        --with-mysql_config=/usr/bin  --libdir=/usr/lib64 \
    && make install \
    && install -D -m644 contribs/slurm_completion_help/slurm_completion.sh /etc/profile.d/slurm_completion.sh \
    && popd \
    && rm -rf slurm \
    && groupadd -r --gid=995 slurm \
    && useradd -r -g slurm --uid=995 slurm \
    && groupadd -r --gid=1001 bench1 \
    && useradd -r -g slurm --uid=1001 bench1 \
    && groupadd -r --gid=1002 bench2 \
    && useradd -r -g slurm --uid=1002 bench2 \
    && mkdir /etc/sysconfig/slurm \
        /var/spool/slurm \
        /var/run/slurm \
        /var/run/slurmdbd \
        /var/lib/slurm \
        /var/log/slurm \
    && touch /var/lib/slurm/node_state \
        /var/lib/slurm/front_end_state \
        /var/lib/slurm/job_state \
        /var/lib/slurm/resv_state \
        /var/lib/slurm/trigger_state \
        /var/lib/slurm/assoc_mgr_state \
        /var/lib/slurm/assoc_usage \
        /var/lib/slurm/qos_usage \
        /var/lib/slurm/fed_mgr_state \
    && chown -R slurm:slurm /var/*/slurm* \
    && /sbin/create-munge-key \
    && chmod 755 /run/munge \
    && mkdir -p /var/spool/slurmd \
    && mkdir -p /var/spool/SLURM

ADD supervisord.conf /etc/supervisord.conf

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
