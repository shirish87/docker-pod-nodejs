FROM node:12-alpine

RUN apk add bash
RUN mkdir -p /var/www/app && \
    echo -e "alias debug='npm run start:debug'\nalias dev='npm run start:dev'\nalias prod='npm run start:prod'" >> ~/.bashrc

ARG NODE_ENV=production
ENV NODE_ENV $NODE_ENV

ARG PORT=3000
ENV PORT $PORT

ENV TSC_VERSION 3.4.3
RUN npm install -g typescript@$TSC_VERSION tsc-watch @nestjs/cli

WORKDIR /var/www/app
COPY ./package.json ./package-*.json ./
RUN npm install --quiet

COPY ./ .

CMD ["npm", "run", "start:prod"]
