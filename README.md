# Nix at European Commission - Summer of Nix

[Summer of Nix][summer of nix website] is a paid summer program where you can
learn, meet, and work with the Nix community. It targets experienced Nixers and
Nix newcomers alike to come together and work on a range of different topics. At
the same time, there will be talks about Nix and presentations by Nix-using
companies with the goal of fostering a strong sense of community and pushing the
ecosystem forward together.

## About

This presentation is about Nix **and** the European Commission, and
about Nix **at** the European Commission. Or: what is the EC doing for
the Nix ecosystem and how is it using Nix?

## Contribute

To load a development shell containing all the tools needed to build the
presentation locally:

```shell
nix develop
```

Then you'll be able to use the `Makefile` to build it once:

```shell
make build
```

or to watch for changes and build the document instantly:

```shell
make watch
```

If you do not want to enter a development shell, just run:

```shell
nix build -o nix-at-ec.pdf
```

to build the presentation once.

[summer of nix website]: https://summer.nixos.org/
