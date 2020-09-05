FROM amd64/alpine:3.12

LABEL maintainer="LSDopen - Stefan Lesicnik (stefan@lsdopen.io)" \
      based_on="fedorage/lnd - rodolphe.franceschi@gmail.com"

ENV LND_VERSION "v0.11.0-beta"

ENV GPG_KEYS_URL "https://keybase.io/roasbeef/pgp_keys.asc"

ENV LND_BASENAME "lnd-linux-amd64-${LND_VERSION}"
ENV LND_ARCHIVE "${LND_BASENAME}.tar.gz"
ENV LND_URL "https://github.com/lightningnetwork/lnd/releases/download/${LND_VERSION}/${LND_ARCHIVE}"

ENV LND_MANIFEST "manifest-${LND_VERSION}.txt"
ENV LND_MANIFEST_SIG "${LND_MANIFEST}.sig"
ENV LND_MANIFEST_URL "https://github.com/lightningnetwork/lnd/releases/download/${LND_VERSION}/${LND_MANIFEST}"
ENV LND_MANIFEST_SIGN_URL "https://github.com/lightningnetwork/lnd/releases/download/${LND_VERSION}/${LND_MANIFEST_SIG}"

ENV LND_GROUP "lnd"
ENV LND_USER "lnd"

ENV DEPENDENCIES ""

# Create lnd user + group
RUN addgroup ${LND_GROUP} && \
    adduser -D -G ${LND_GROUP} ${LND_USER}

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
    && wget -qO ${LND_MANIFEST} "${LND_MANIFEST_URL}" \
    && wget -qO ${LND_MANIFEST_SIG} "${LND_MANIFEST_SIGN_URL}" \
    && gpg --verify ${LND_MANIFEST_SIG} ${LND_MANIFEST} \
    # Get LND and check the signature in the manifest
    && wget -qO ${LND_ARCHIVE} "${LND_URL}" \
    && SIGNATURELINE=$(sha256sum ${LND_ARCHIVE}) \
    && grep ${SIGNATURELINE} ${LND_MANIFEST} \
    # Install
    && tar -xzvf ${LND_ARCHIVE} \
    && mv ${LND_BASENAME}/* /usr/local/bin/ \
    && chmod a+x /usr/local/bin/lncli /usr/local/bin/lnd \
    # Cleanup 
    && rm -rf /tmp/${LND_BASENAME} /tmp/${LND_ARCHIVE} 

# Cleanup dependencies
RUN apk del /tmp/.build-deps

# Install apps we may want
RUN apk add bash

# Create data directory
ENV LND_DATA /data
RUN mkdir "$LND_DATA" \
	&& chown -R ${LND_USER}:${LND_GROUP} "$LND_DATA" \
	&& ln -sfn "$LND_DATA" /home/${LND_USER}/.lnd \
	&& chown -h ${LND_USER}:${LND_GROUP} /home/${LND_USER}/.lnd
VOLUME /data

# Clear ENV variables
RUN unset LND_GROUP LND_USER LND_VERSION LND_BASENAME LND_ARCHIVE LND_URL GPG_KEYS_URL LND_MANIFEST LND_MANIFEST_SIG LND_MANIFEST_URL LND_MANIFEST_SIGN_URL

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

USER lnd
CMD ["lnd"]
