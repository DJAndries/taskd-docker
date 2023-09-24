# Taskserver Docker image

![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/darnellandries/taskd?sort=date&style=for-the-badge)

A simple taskd image updated monthly. Includes convenient management scripts.

## Setup

1. Use the supplied Compose file, or copy the `taskd` service definition into another Compose file.
2. Set the environment variables for the taskd initialization in the docker-compose or in a file called `.env` and uncomment the corresponding line (choose any name, but modify the docker-compose accordingly). **localhost cannot be used as the hostname**.
3. Run `docker compose up -d` to start the application.
4. Exec inside the container with `docker exec taskd sh`.
5. Run `taskd-add-user [organization-name] [user-name]`. Filenames for the CA/client key/certificates and the new user key will be outputted.
6. Exit the shell/container and start the taskd service via `docker compose up -d`.
7. Copy the CA/client key/certificates out of the container volume.
  * `docker compose cp taskd:/var/lib/taskd/ca.cert.pem .`
  * `docker compose cp taskd:/var/lib/taskd/[user-name].cert.pem .`
  * `docker compose cp taskd:/var/lib/taskd/[user-name].key.pem .`

### Client setup

1. Copy the CA/client key/certificates into the `~/.task` directory.
2. Add the key/certificates to the configuration.
  * `task config taskd.certificate -- ~/.task/[user-name].cert.pem`
  * `task config taskd.key -- ~/.task/[user-name].key.pem`
  * `task config taskd.ca -- ~/.task/ca.cert.pem`
3. Add the server host and port to the configuration: `task config taskd.server -- [hostname]:53589`
4. Add the user credentials to the configuration: `task config taskd.credentials -- [organization-name]/[user-name]/[user key from the add user command]`
5. Run `task sync` and enjoy.

## Renewing/regenerating certificates

By default, the certificates expire after 365 days. Override this value with the `TASKD_CERT_EXPIRATION_DAYS` env variable.

To renew/regenerate the certificates, run `taskd-generate-server-key` for CA/server keys, and run `taskd-generate-client-key [user-name]` for each client certificate.
