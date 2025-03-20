FROM nginx:alpine

WORKDIR /app

RUN apk add --no-cache pandoc bash

COPY . /app

RUN chmod +x /app/scripts/convert.sh && /app/scripts/convert.sh

RUN mv /app/output/* /usr/share/nginx/html/

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
