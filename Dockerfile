FROM node:18 AS builder

ARG APP_NAME
ARG APP_VERSION

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN echo "Building $APP_NAME Version $APP_VERSION"

FROM node:18-alpine

ARG APP_NAME
ARG APP_VERSION

ENV APP_NAME=$APP_NAME
ENV APP_VERSION=$APP_VERSION

LABEL app.name=$APP_NAME
LABEL app.version=$APP_VERSION

WORKDIR /app

COPY --from=builder /app .

EXPOSE 3000

CMD ["npm","start"]
