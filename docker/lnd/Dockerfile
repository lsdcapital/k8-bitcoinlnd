FROM amd64/alpine:3.12

LABEL maintainer="LSDopen - Stefan Lesicnik (stefan@lsdopen.io)" \
      based_on="fedorage/lnd - rodolphe.franceschi@gmail.com"

ENV APP_VERSION "v0.11.1-beta"

ENV GPG_KEYS_URL "https://keybase.io/bitconner/pgp_keys.asc"

ENV APP_BASENAME "lnd-linux-amd64-${APP_VERSION}"
ENV APP_ARCHIVE "${APP_BASENAME}.tar.gz"
ENV APP_URL "https://github.com/lightningnetwork/lnd/releases/download/${APP_VERSION}/${APP_ARCHIVE}"

ENV APP_MANIFEST "manifest-${APP_VERSION}.txt"
ENV APP_MANIFEST_SIG "${APP_MANIFEST}.sig"
ENV APP_MANIFEST_URL "https://github.com/lightningnetwork/lnd/releases/download/${APP_VERSION}/${APP_MANIFEST}"
ENV APP_MANIFEST_SIGN_URL "https://github.com/lightningnetwork/lnd/releases/download/${APP_VERSION}/${APP_MANIFEST_SIG}"

ENV APP_GROUP "lnd"
ENV APP_USER "lnd"

ENV DEPENDENCIES ""

# Create lnd user + group
RUN addgroup ${APP_GROUP} && \
    adduser -D -G ${APP_GROUP} ${APP_USER}

# Install dependencies
RUN apk add --no-cache --virtual /tmp/.build-deps \
    gnupg \
    curl \
    outils-sha256

# Download / Check / Install
RUN cd /tmp \
    # Get and import pgp signing key
    && curl ${GPG_KEYS_URL} | gpg --import \
    # Get Manifest and check it
    && wget -qO ${APP_MANIFEST} "${APP_MANIFEST_URL}" \
    && wget -qO ${APP_MANIFEST_SIG} "${APP_MANIFEST_SIGN_URL}" \
    && gpg --verify ${APP_MANIFEST_SIG} ${APP_MANIFEST} \
    # Get LND and check the signature in the manifest
    && wget -qO ${APP_ARCHIVE} "${APP_URL}" \
    && SIGNATURELINE=$(sha256sum ${APP_ARCHIVE}) \
    && grep ${SIGNATURELINE} ${APP_MANIFEST} \
    # Install
    && tar -xzvf ${APP_ARCHIVE} \
    && mv ${APP_BASENAME}/* /usr/local/bin/ \
    && chmod a+x /usr/local/bin/lncli /usr/local/bin/lnd \
    # Cleanup 
    && rm -rf /tmp/${APP_BASENAME} /tmp/${APP_ARCHIVE} 

# Cleanup dependencies
RUN apk del /tmp/.build-deps

# Install apps we may want
RUN apk add bash

# Create data directory
ENV APP_DATA /data
RUN mkdir "$APP_DATA" \
	&& chown -R ${APP_USER}:${APP_GROUP} "$APP_DATA" \
	&& ln -sfn "$APP_DATA" /home/${APP_USER}/.lnd \
	&& chown -h ${APP_USER}:${APP_GROUP} /home/${APP_USER}/.lnd
VOLUME /data

# Clear ENV variables
RUN unset APP_GROUP APP_USER APP_VERSION APP_BASENAME APP_ARCHIVE APP_URL GPG_KEYS_URL APP_MANIFEST APP_MANIFEST_SIG APP_MANIFEST_URL APP_MANIFEST_SIGN_URL

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

USER lnd
CMD ["lnd"]
