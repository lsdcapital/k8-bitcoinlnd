FROM node:10-alpine

LABEL maintainer="LSDopen - Stefan Lesicnik (stefan@lsdopen.io)"

ENV LNDHUB_VERSION "v1.2.0"

ENV LNDHUB_ARCHIVE "${LNDHUB_VERSION}.tar.gz"
ENV LNDHUB_URL "https://github.com/BlueWallet/LndHub/archive/${LNDHUB_ARCHIVE}"

ENV LNDHUB_USER "lndhub"
ENV LNDHUB_GROUP "lndhub"

ENV DEPENDENCIES ""

# Create lndhub user + group
RUN addgroup ${LNDHUB_GROUP} && \
    adduser -D -G ${LNDHUB_GROUP} ${LNDHUB_USER}

# # Install dependencies
# RUN apk add --no-cache --virtual /tmp/.build-deps \
#     gnupg \
#     curl \
#     outils-sha256

# Create data directory
ENV LNDHUB_DATA /lndhub
RUN mkdir "$LNDHUB_DATA" \
	&& chown -R ${LNDHUB_USER}:${LNDHUB_GROUP} "$LNDHUB_DATA"

# Download / Check / Install
RUN cd /tmp \
    && mkdir /tmp/lndhub \
    # Get LNDHUB
    && wget -qO ${LNDHUB_ARCHIVE} "${LNDHUB_URL}" \
    # Install
    && tar -xzvf ${LNDHUB_ARCHIVE} -C /tmp/lndhub --strip-components=1 \
    # Cleanup downloaded archive
    && rm -rf /tmp/${LNDHUB_ARCHIVE}

# Cleanup dependencies
#RUN apk del /tmp/.build-deps

#Install LNDHUB
RUN cd /tmp/lndhub \
    && npm config set prefix '~/.npm-global' \
    && export PATH=~/.npm-global/bin:$PATH \
    && npm install \
    && npm install -g babel-cli \
    && babel ./ --out-dir /lndhub --copy-files --ignore node_modules

# Set permissions
RUN chown -R ${LNDHUB_USER}:${LNDHUB_GROUP} "$LNDHUB_DATA"

# Cleanup dependencies
RUN rm -rf /tmp/lndhub

# Clear ENV variables
RUN unset LNDHUB_GROUP LNDHUB_USER LNDHUB_VERSION LNDHUB_BASENAME LNDHUB_ARCHIVE LNDHUB_URL
VOLUME /lndhub

# Install additional apps we may want
RUN apk add bash

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3000

USER lndhub
CMD ["node /lndhub/index.js"]
