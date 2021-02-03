FROM opensciencegrid/software-base:fresh
LABEL maintainer "OSG Software <help@opensciencegrid.org>"

RUN yum install -y --enablerepo=osg-testing \
                   --enablerepo=osg-upcoming-testing \
                   osg-ce-bosco \
                   # FIXME: avoid htcondor-ce-collector conflict
                   htcondor-ce \
                   htcondor-ce-view \
                   git \
                   openssh-clients \
                   sudo \
                   wget \
                   certbot \
                   perl-LWP-Protocol-https \
                   # ^^^ for fetch-crl, in the rare case that the CA forces HTTPS
                   patch && \
    yum clean all && \
    rm -rf /var/cache/yum/

COPY 25-hosted-ce-setup.sh /etc/osg/image-config.d/
COPY 30-remote-site-setup.sh /etc/osg/image-config.d/
COPY 50-nonroot-gratia-setup.sh /etc/osg/image-config.d/

COPY 99-container.conf /usr/share/condor-ce/config.d/

# do the bad thing of overwriting the existing cron job for fetch-crl
ADD fetch-crl /etc/cron.d/fetch-crl
RUN chmod 644 /etc/cron.d/fetch-crl

# HACK: override condor_ce_jobmetrics from SOFTWARE-4183 until it is released in
# HTCondor-CE.
ADD overrides/condor_ce_jobmetrics /usr/share/condor-ce/condor_ce_jobmetrics

# Include script to drain the CE and upload accounting data to prepare for container teardown
COPY drain-ce.sh /usr/local/bin/

COPY configure-nonroot-gratia.py /usr/local/bin/

# Use "ssh -q" in bosco_cluster and update-remote-wn-client until the changes have been
# upstreamed to condor and hosted-ce-tools packaging, respectively
COPY overrides/ssh_q.patch /tmp
RUN patch -d / -p0 < /tmp/ssh_q.patch

# Enable bosco_cluster xtrace
COPY overrides/bosco_cluster_xtrace.patch /tmp
RUN patch -d / -p0 < /tmp/bosco_cluster_xtrace.patch

# HACK: Don't copy over the SSH pub key to the remote side. We set
# this up with the site out of band.
COPY overrides/skip_key_copy.patch /tmp
RUN patch -d / -p0 < /tmp/skip_key_copy.patch

# Set up Bosco override dir from Git repo (SOFTWARE-3903)
# Expects a Git repo with the following directory structure:
#     RESOURCE_NAME_1/
#         bosco_override/
#         ...
#     RESOURCE_NAME_2/
#         bosco_override/
#         ...
#     ...
COPY bosco-override-setup.sh /usr/local/bin

# Manage HTCondor-CE with supervisor
COPY 10-htcondor-ce.conf /etc/supervisord.d/

