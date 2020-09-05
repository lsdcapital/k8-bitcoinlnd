FROM node:10-alpine

LABEL maintainer="LSDopen - Stefan Lesicnik (stefan@lsdopen.io)"

ENV LNDHUB_VERSION "v1.2.0"

ENV LNDHUB_BASENAME "{LNDHUB_VERSION}"
ENV LNDHUB_ARCHIVE "${LNDHUB_BASENAME}.tar.gz"
ENV LNDHUB_URL "https://github.com/BlueWallet/LndHub/archive/${LNDHUB_ARCHIVE}"

ENV LNDHUB_USER "lndhub"
ENV LNDHUB_GROUP "lndhub"

ENV DEPENDENCIES ""

# Create lndhub user + group
RUN addgroup ${LNDHUB_GROUP} && \
    adduser -D --no-create-home -G ${LNDHUB_GROUP} ${LNDHUB_USER}

# Install dependencies
RUN apk add --no-cache --virtual /tmp/.build-deps \
    gnupg \
    curl \
    outils-sha256

# Download / Check / Install
RUN cd /tmp \
    # Get LNDHUB
    && wget -qO ${LNDHUB_ARCHIVE} "${LNDHUB_URL}" \
    # Install
    && tar -xzvf ${LNDHUB_ARCHIVE} \
    && mv ${LNDHUB_BASENAME}/* /lndhub \
    # Cleanup 
    && rm -rf /tmp/${LNDHUB_BASENAME} /tmp/${LND_ARCHIVE} 

# Cleanup dependencies
RUN apk del /tmp/.build-deps

# Install apps we may want
RUN apk add bash

# Create data directory
ENV LNDHUB_DATA /lndhub
RUN mkdir "$LNDHUB_DATA" \
	&& chown -R ${LNDHUB_USER}:${LNDHUB_GROUP} "$LND_DATA" \
VOLUME /lndhub

RUN npm install -g express
RUN npm install --save helmet
RUN npm i

# Clear ENV variables
RUN unset LNDHUB_GROUP LNDHUB_USER LNDHUB_VERSION LNDHUB_BASENAME LNDHUB_ARCHIVE LNDHUB_URL

COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3000

USER lndhub
CMD ["/lndhub/node_modules/.bin/babel-node index.js"]
