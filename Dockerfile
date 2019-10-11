FROM node:10-alpine

# Create app directory

WORKDIR /usr/src/app

# Install app dependencies

COPY package.json ./

RUN yarn install

COPY . .

EXPOSE 3000

CMD [ "yarn", "start" ]