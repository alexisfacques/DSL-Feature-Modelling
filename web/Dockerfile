FROM node:alpine

# Installing Java 8
RUN apk --update add openjdk8-jre

# App directory
WORKDIR /usr/src/app

# Installing app dependencies
COPY package.json .
COPY package-lock.json .
COPY tsconfig.json .

# Copying app sources
COPY ./src ./src
COPY ./data ./data
COPY ./bin ./bin
COPY ./angular-src ./angular-src

# Building angular application
WORKDIR angular-src
RUN npm install \
    && node_modules/@angular/cli/bin/ng build

# Building application
WORKDIR /usr/src/app
RUN npm install \
    && npm run build

# HTTP Server
EXPOSE 8080

CMD npm start
