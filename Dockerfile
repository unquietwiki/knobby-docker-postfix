# Knobby Dockerized Postfix
#
# VERSION 1.0

FROM debian:stable

LABEL Description="Fork of docker-postfix-relay, with a lot more knobs."

ARG EXT_DOMAIN
ARG EXT_HOST
ARG LOCAL_DELIVER
ARG MESSAGE_SIZE_LIMIT
ARG SRC_NETWORKS
ARG SECURITY_OPTIONS
ARG DUMB_INIT_VER

VOLUME /var/log /var/spool/postfix

RUN echo "===== Software and Filesystem Provisioning ======" && \
mkdir -p /var/spool/postfix/dev/log && \
apt-get update && \
apt-get dist-upgrade -yqq && \
echo "postfix postfix/mailname string {$EXT_DOMAIN}" | debconf-set-selections && \
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections && \
apt-get install -yqq bzip2 ca-certificates curl file iproute2 libatm1 libsasl2-modules libterm-readline-gnu-perl libxtables12 logrotate postfix publicsuffix rsyslog xz-utils && \
apt-get autoremove -yqq && \
apt-get clean -yqq && \
curl -Lk -o /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VER}/dumb-init_${DUMB_INIT_VER}_amd64 && \
chmod +x /usr/local/bin/dumb-init

ADD postfix /etc/postfix
ADD entrypoint sendmail_test /usr/local/bin/

RUN echo "===== echo Configuring Postfix =====" && \
chmod a+rx /usr/local/bin/* && \
/usr/sbin/postconf -e myhostname=${EXT_HOST} && \
/usr/sbin/postconf -e mydestination=${LOCAL_DELIVER} && \
/usr/sbin/postconf -e mydomain=${EXT_DOMAIN} && \
/usr/sbin/postconf -e mynetworks='${SRC_NETWORKS}' && \
/usr/sbin/postconf -e inet_interfaces=all && \
/usr/sbin/postconf -e smtp_sasl_auth_enable=yes && \
/usr/sbin/postconf -e smtp_sasl_password_maps='hash:/etc/postfix/sasl/sasl_passwd' && \
/usr/sbin/postconf -e smtp_sasl_security_options=${SECURITY_OPTIONS} && \
/usr/sbin/postconf -e smtp_tls_security_level=may && \
/usr/sbin/postconf -e smtp_helo_name=${EXT_HOST}.${EXT_DOMAIN} && \
/usr/sbin/postmap /etc/postfix/sasl/sasl_passwd

ENTRYPOINT ["/usr/local/bin/dumb-init", "--", "/usr/local/bin/entrypoint"]
CMD ["tail", "-f", "/var/log/mail.log"]
