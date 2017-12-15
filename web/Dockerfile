FROM node:alpine

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package.json .
COPY package-lock.json .
COPY tsconfig.json .

RUN npm install

# Bundle app sources
COPY ./src ./src
COPY ./app ./app

# Building the app
RUN npm run build

# AMQP port. Not sure if needed
EXPOSE 5672

# HTTP Server
EXPOSE 8080


CMD npm start
