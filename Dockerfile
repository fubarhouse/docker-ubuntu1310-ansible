FROM ubuntu:13.10
MAINTAINER Karl Hepworth

# Convert sources to legacy.
RUN sed -i.bak -r 's/(archive|security).ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list

# Install dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       python-dev python-setuptools python-pip make make git curl \
       python python-yaml python-paramiko python-jinja2 python-httplib2 \
       python-software-properties software-properties-common \
       rsyslog gcc sudo build-essential wget \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean
RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf
#ADD etc/rsyslog.d/50-default.conf /etc/rsyslog.d/50-default.conf

# Upgrade python
RUN wget https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tgz \
    && tar zxf ./Python-2.7.13.tgz \
    && cd Python-2.7.13 \
    && ./configure \
    && make \
    && make install \
    && rm -f ../Python-2.7.13.tgz

# Install Ansible via pip.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential libffi-dev libssl-dev python-pip python-dev \
       zlib1g-dev libncurses5-dev systemd python-setuptools \
    && rm -rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean
RUN pip install urllib3 pyOpenSSL ndg-httpsclient pyasn1 cryptography
RUN pip install --upgrade pip virtualenv virtualenvwrapper
RUN pip install ansible==2.1

COPY initctl_faker .
RUN chmod +x initctl_faker && rm -fr /sbin/initctl && ln -s /initctl_faker /sbin/initctl

# Install Ansible inventory file
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# Report some information
RUN python --version
RUN ansible --version