FROM node:10-stretch

LABEL maintainer="LSDopen - Stefan Lesicnik (stefan@lsdopen.io)"

RUN groupadd -r lndhubuser -g 1000 && useradd -d /home/lndhubuser -u 1000 -r -g lndhubuser lndhubuser
RUN mkdir /home/lndhubuser/ && chown -R 1000:1000 /home/lndhubuser/
COPY LndHub/ /lndhub/
WORKDIR /lndhub/

RUN npm install -g express
RUN npm install --save helmet
RUN npm i
RUN mkdir /lndhub/logs && chown -R 1000:1000 /lndhub/

USER lndhubuser

EXPOSE 3000

# Define default command
CMD /lndhub/node_modules/.bin/babel-node index.js