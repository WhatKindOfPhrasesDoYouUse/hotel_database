FROM postgres:17

ENV LANG en_US.utf8

ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=root
ENV POSTGRES_DB=hotel_database

COPY start_init.sql /docker-entrypoint-initdb.d/

EXPOSE 5432
