FROM almalinux:9

LABEL maintener="myself"

ARG BUILD_DATE
ARG SLURM_VERSION

LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="slurm/"$SLURM_VERSION
LABEL org.label-schema.description="Slurm POC container w/AlmaLinux 9"
LABEL org.label-schema.version=$SLURM_VERSION
LABEL org.label-schema.docker.cmd="docker-compose up -d"

RUN echo -e "[mariadb]\n\
name = MariaDB\n\
baseurl = https://archive.mariadb.org/mariadb-11.3.2/yum/almalinux9-amd64\n\
gpgkey=https://archive.mariadb.org/PublicKey\n\
gpgcheck=1\
" > /etc/yum.repos.d/mariadb.repo

RUN dnf install -y epel-release \
    && dnf config-manager --set-enabled crb
    
RUN set -ex \
    && dnf makecache fast \
    && dnf -y update \
    && dnf -y install epel-release \
    && dnf -y install \
       wget \
       man-db \
       bzip2 \
       perl \
       gcc \
       gcc-c++\
       git \
       gnupg \
       make \
       munge \
       munge-libs \
       munge-devel \
       python-devel \
       python-pip \
       python3 \
       python3-devel \
       python3-pip \
       psmisc \
       bash-completion \
       supervisor \
       MariaDB-client \
       MariaDB-devel \
       vim-enhanced \
       openmpi \
       openmpi-devel \
    && dnf clean all \
    && rm -rf /var/cache/yum

#RUN ln -s /usr/bin/python3.4 /usr/bin/python3

RUN pip install Cython nose && pip3 install Cython nose


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
    && groupadd -r --gid=911 slurm \
    && useradd -r -g slurm --uid=911 slurm \
    && groupadd -r --gid=1011 bench1 \
    && useradd -r -g bench1 --uid=1011 bench1 \
    && groupadd -r --gid=1012 bench2 \
    && useradd -r -g bench2 --uid=1012 bench2 \
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
    && mkdir -p /var/spool/SLURM \
    && chown slurm:slurm /var/spool/SLURM \
    && mkdir -p /etc/slurm/ \
    && touch /etc/slurm/slurm.conf \
    && touch /etc/slurm/slurmdbd.conf \
    && touch /etc/slurm/partition.conf \
    && chown slurm:slurm /etc/slurm/*.conf \
    && chmod 644 /etc/slurm/slurm.conf \
    && chmod 600 /etc/slurm/slurmdbd.conf \
    && chmod 644 /etc/slurm/partition.conf

RUN echo 'alias sacct_="\sacct -D --format=jobid%-13,user%-12,jobname%-35,submit,timelimit,partition,qos,nnodes,start,end,elapsed,state,exitcode%-6,Derivedexitcode%-6,nodelist%-200 "' >> /root/.bashrc \
    && echo 'alias sinfo_="\sinfo --format=\"%100E %12U %19H %6t %N\" "' >> /root/.bashrc

ADD supervisord.conf /etc/supervisord.conf

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]

