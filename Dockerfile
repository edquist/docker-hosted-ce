FROM opensciencegrid/software-base:fresh
LABEL maintainer "Lincoln Bryant <lincolnb@uchicago.edu>"

RUN yum install -y yum-plugin-priorities && \
yum install -y --enablerepo=devops-production hosted-ce-tools osg-ca-certs osg-ce-bosco fetch-crl \
gratia-probes-cron openssh openssh-clients certbot && yum clean all

COPY hosted-ce-setup.sh /etc/osg/image-config.d/hosted-ce-setup.sh
#COPY hosted-ce.conf /etc/supervisord.d/hosted-ce.conf
COPY remote-site-setup.sh /etc/osg/remote-site-setup.sh

COPY install-resource.sh /etc/osg/install-resource.sh

# can be dropped when provided by upstream htcondor-ce packaging
COPY 51-gratia.conf /usr/share/condor-ce/config.d/51-gratia.conf

COPY bosco-cluster-remote-hosts.sh /usr/local/bin/bosco-cluster-remote-hosts.sh
COPY bosco-cluster-remote-hosts.py /usr/local/bin/bosco-cluster-remote-hosts.py

# do the bad thing of overwriting the existing cron job for fetch-crl
ADD fetch-crl /etc/cron.d/fetch-crl

#ENTRYPOINT ["osg-configure","-c"]
ENTRYPOINT ["/usr/local/sbin/supervisord_startup.sh"]
