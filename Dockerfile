ARG NODE_VERSION=18
ARG FRONT_DIR_BASE=.
ARG FRONT_WORK_DIR=/usr/src/app
ARG BACKEND_ADDRESS="/api"

FROM node:${NODE_VERSION}-alpine as frontend-base
ARG FRONT_WORK_DIR
ARG BACKEND_ADDRESS
WORKDIR ${FRONT_WORK_DIR}
ARG FRONT_DIR_BASE
RUN --mount=type=bind,source=${FRONT_DIR_BASE}/package.json,target=package.json \
    --mount=type=cache,target=/root/.npm \
    npm install && \
    mkdir -p node_modules/.cache && chmod -R 777 node_modules/.cache && \
    mkdir -p build && chmod -R 777 build
USER node
COPY ${FRONT_DIR_BASE} .
ENV REACT_APP_API_BASE_URL=$BACKEND_ADDRESS
RUN npm run build

FROM frontend-base as frontend-dev
EXPOSE 3000
ENTRYPOINT [ "npm", "run", "start" ]

FROM nginx:alpine as frontend-prod
ARG FRONT_WORK_DIR
COPY --from=frontend-base ${FRONT_WORK_DIR}/build /usr/share/nginx/html
COPY ./nginx-templates/* /etc/nginx/templates/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
