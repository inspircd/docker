FROM centos:7
MAINTAINER Adam adam@anope.org

ADD packages.sigterm.info.repo /etc/yum.repos.d/

RUN yum upgrade -y
RUN yum install -y inspircd

USER ircd
EXPOSE 6667
ENTRYPOINT /usr/sbin/inspircd --config=/etc/inspircd/inspircd.conf --nofork
