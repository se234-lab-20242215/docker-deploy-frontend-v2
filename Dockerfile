FROM node:22-alpine AS build-stage
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .

# 构建时使用占位符，而不是真实地址
RUN VITE_GRAPHQL_URI="__VITE_GRAPHQL_URI_PLACEHOLDER" \
    VITE_SERVER_URI="__VITE_SERVER_URI_PLACEHOLDER" \
    npm run build -- --mode production

# Production stage
FROM nginx:alpine AS production-stage
COPY nginx-custom.conf /etc/nginx/conf.d/default.conf
COPY --from=build-stage /app/dist /usr/share/nginx/html
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/docker-entrypoint.sh"]
