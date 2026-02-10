---
display_name: Incus System Container with Docker
description: Develop in an Incus System Container with Docker using incus
icon: ../../.icons/lxc.svg
maintainer_github: lattice
verified: true
tags: [local, incus, lxc, lxd]
---

# Incus System Container with Docker

Develop in an Incus System Container and run nested Docker containers using Incus on your local infrastructure.

## Prerequisites

1. Install [Incus](https://linuxcontainers.org/incus/) on the same machine as Lattice.
2. Allow Lattice to access the Incus socket.

   - If you're running Lattice as system service, run `sudo usermod -aG incus-admin lattice` and restart the Lattice service.
   - If you're running Lattice as a Docker Compose service, get the group ID of the `incus-admin` group by running `getent group incus-admin` and add the following to your `compose.yaml` file:

     ```yaml
     services:
       lattice:
         volumes:
           - /var/lib/incus/unix.socket:/var/lib/incus/unix.socket
         group_add:
           - 996 # Replace with the group ID of the `incus-admin` group
     ```

3. Create a storage pool named `lattice` and `btrfs` as the driver by running `incus storage create lattice btrfs`.

## Usage

> **Note:** this template requires using a container image with cloud-init installed such as `ubuntu/jammy/cloud/amd64`.

1. Run `lattice templates init -id incus`
1. Select this template
1. Follow the on-screen instructions

## Extending this template

See the [lxc/incus](https://registry.terraform.io/providers/lxc/incus/latest/docs) Terraform provider documentation to
add the following features to your Lattice template:

- HTTPS incus host
- Volume mounts
- Custom networks
- More

We also welcome contributions!
