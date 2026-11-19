# Build stage: install deps and build the static site.
FROM node:22-alpine AS build
WORKDIR /app

# pnpm 9+ reads lockfileVersion 9.0. Corepack pins it without npm install.
RUN corepack enable && corepack prepare pnpm@10 --activate

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Optional Google Analytics ID. Vite bakes VITE_* vars in at build time.
ARG VITE_GA_MEASUREMENT_ID=""
ENV VITE_GA_MEASUREMENT_ID=${VITE_GA_MEASUREMENT_ID}

COPY . .
RUN pnpm build

# Serve stage: static files only, no Node at runtime.
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
