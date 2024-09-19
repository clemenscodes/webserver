# Example Web Server

## Installation

There are several supported methods to install and run this project.
For unix systems, the recommended way is to use [nix](https://nixos.org/download/#download-nix).

### Using [nix](https://nixos.org/download/#download-nix)

```sh
nix run github:clemenscodes/kickbase
```

On Windows, using nix in [WSL2](https://learn.microsoft.com/de-de/windows/wsl/about#what-is-wsl-2)
works fine.

Alternatively, use either [proto](https://moonrepo.dev/docs/proto) or [docker](https://www.docker.com/).

First clone this repository using [git](https://git-scm.com/).

```sh
git clone https://clemenscodes/kickbase.git
cd kickbase
```

### Using [proto](https://moonrepo.dev/docs/proto/install)

Initialize the toolchains and build.

```sh
proto setup
proto use
moon setup
moon sync projects
moon run start
```

### Using [docker](https://docs.docker.com/engine/install/)

Start the container.

```sh
docker compose up
```

## Building

The server hosts styles at runtime which have to be built first using [Tailwind](https://tailwindcss.com/).
Use your favorite JavaScript package manager to install `tailwindcss`.

### Build using [moon](https://moonrepo.dev/docs)

When using moon, [bun](https://bun.sh/) is used by default to install `tailwindcss`.

```sh
moon run build
```

### Build using [nix](https://nixos.org/download/#download-nix)

```sh
nix build
```

### Using [cargo](https://doc.rust-lang.org/cargo/getting-started/installation.html)

```sh
tailwindcss -i styles/tailwind.css -o assets/main.css
cargo build --release
```

## Running

### Run using [cargo](https://doc.rust-lang.org/cargo/getting-started/installation.html)

```sh
tailwindcss -i styles/tailwind.css -o assets/main.css
cargo run --release
```

### Run using [nix](https://nixos.org/download/#download-nix)

```sh
nix run
```

## Developing

### Develop using [nix](https://nixos.org/download/#download-nix)

```sh
nix develop -c $SHELL
moon run dev
```

### Develop using [moon](https://moonrepo.dev/docs)

```sh
moon run dev
```

### Develop using [cargo](https://doc.rust-lang.org/cargo/getting-started/installation.html)

```sh
cargo watch -c -w src -w templates -w styles -- \
  bunx tailwindcss -i styles/tailwind.css -o assets/main.css && \
  cargo run
```
