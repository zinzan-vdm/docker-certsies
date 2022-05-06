FROM alpine:latest
LABEL VERSION=1.0.0

# This image is massively inspired by the https://github.com/matrix-org/docker-dehydrated project.

ADD --chmod=555 app /app

VOLUME /certsies

RUN /app/installers/install.sh \
  && rm -fR /app/installers

ENV \
  CONFIGURE="yes" \
  DEHYDRATED_CA="https://acme-staging-v02.api.letsencrypt.org/directory" \
  DEHYDRATED_CHALLENGE="http-01" \
  DEHYDRATED_HOOK="/app/hooks/invoke.sh" \
  DEHYDRATED_KEYSIZE="4096" \
  DEHYDRATED_KEY_ALGO="rsa" \
  DEHYDRATED_RENEW_DAYS="30" \
  DEHYDRATED_KEY_RENEW="yes" \
  DEHYDRATED_ACCEPT_TERMS="no" \
  DEHYDRATED_EMAIL=""

ENTRYPOINT "/app/run.sh"
