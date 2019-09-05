FROM balenalib/raspberrypi3-alpine

RUN apk add nodejs npm build-base python

RUN apk add zeromq-dev

WORKDIR /app

COPY .npmrc .npmrc
COPY package.json package.json

RUN npm install

COPY . .

RUN npm run-script build

ENTRYPOINT ["/usr/bin/npm"]

CMD ["start"]
