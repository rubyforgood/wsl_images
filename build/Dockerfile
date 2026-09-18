FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# Base developer tooling, PostgreSQL, MariaDB, and native-extension dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        build-essential \
        ca-certificates \
        curl \
        git \
        gh \
        libmariadb-dev \
        libpq-dev \
        libvips \
        locales \
        mariadb-server \
        openssh-client \
        pkg-config \
        postgresql \
        sudo \
        unzip \
        vim \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Create the default WSL user.
# Passwordless sudo is intentional for a disposable local contributor environment.
RUN useradd \
        --create-home \
        --shell /bin/bash \
        --groups sudo \
        dev \
    && echo 'dev ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/dev \
    && chmod 0440 /etc/sudoers.d/dev

# Install Starship system-wide.
RUN curl --fail --show-error --silent --location \
        https://starship.rs/install.sh \
    | sh -s -- --yes

# Configure PostgreSQL.
#
# The `postgres` role is created by PostgreSQL itself and is a superuser.
# Create a PostgreSQL role for the Linux `dev` user with privileges needed
# for Rails to create and manage application databases.
#
# No application database is created here. Rails is responsible for creating
# databases through tasks such as `bin/rails db:create` or `bin/rails db:prepare`.
RUN service postgresql start \
    && su --shell /bin/bash postgres --command \
        "psql --command \"ALTER ROLE postgres WITH PASSWORD 'password'; CREATE ROLE dev WITH LOGIN SUPERUSER CREATEDB CREATEROLE PASSWORD 'password';\"" \
    && service postgresql stop

# Configure MariaDB.
#
# The root database account has an intentionally blank password for local
# development. The `dev` account is also available for applications that use
# a non-root database user and can create and manage databases.
# No application database is created here; Rails creates databases through
# tasks such as `bin/rails db:create` or `bin/rails db:prepare`.
RUN service mariadb start \
    && mariadb --execute \
        "ALTER USER 'root'@'localhost' IDENTIFIED BY ''; CREATE USER 'dev'@'%' IDENTIFIED BY 'password'; GRANT ALL PRIVILEGES ON *.* TO 'dev'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;" \
    && service mariadb stop

# WSL configuration:
COPY config/wsl.conf /etc/wsl.conf
COPY config/wsl-distribution.conf /etc/wsl-distribution.conf
COPY assets/ruby-for-good.ico /usr/lib/wsl/ruby-for-good.ico
COPY templates/ruby-for-good-terminal-profile.json /usr/lib/wsl/ruby-for-good-terminal-profile.json

# First-run onboarding script for Git identity, GitHub authentication,
# and optional Ruby for Good repository cloning.
COPY --chown=dev:dev scripts/rfg-setup.sh /usr/local/bin/rfg-setup
RUN chmod 0755 /usr/local/bin/rfg-setup

# Set up user-scoped tools and shell configuration.
USER dev
WORKDIR /home/dev

# Install mise as `dev`, so its executable is owned by the contributor
# account rather than root.
RUN curl --fail --show-error --silent --location \
        https://mise.run \
    | sh

# Make mise itself available. Bash activation adds configured tool versions
# to PATH when a shell starts. Mise shims are intentionally omitted.
ENV PATH="/home/dev/.local/bin:${PATH}"

COPY --chown=dev:dev templates/config.toml /home/dev/.config/mise/config.toml

RUN mise trust /home/dev/.config/mise/config.toml \
    && mise install \
    && mkdir -p /home/dev/.config \
    && starship preset no-nerd-font \
        --output /home/dev/.config/starship.toml \
    && { \
        echo ''; \
        echo '# Ruby for Good contributor environment'; \
        echo 'eval "$($HOME/.local/bin/mise activate bash)"'; \
        echo 'eval "$(starship init bash)"'; \
        echo ''; \
        echo '# First-run onboarding. Re-run with: rfg-setup --force'; \
        echo '[ -f "$HOME/.rfg-setup-complete" ] || /usr/local/bin/rfg-setup'; \
      } >> /home/dev/.bashrc

WORKDIR /home/dev

CMD ["/bin/bash"]
