vagrant-smartos-packager
========================

Create Vagrant boxes of the latest SmartOS platform image.

This repository includes scripts to help create SmartOS Vagrant
boxes. The box created will be a Vagrant-capable global zone,
into which local zones can be installed with the vagrant plugin
[vagrant-smartos-zones](https://github.com/sax/vagrant-smartos-zones).

## Dependencies

* VirtualBox >= 4.3
* Vagrant >= 1.5.2

## Usage

Download the latest SmartOS platform image and turn it into
a VirtualBox VM.

```bash
./bin/mksmartvm
```

When the VM spins up in VirtualBox, use the default networking
options. Set the root password to be `vagrant`.

Now log in via ssh:

```bash
ssh localhost -p 2222 -l root
```

### Creating barebones global zone

```bash
curl -k https://raw.github.com/sax/vagrant-smartos-packager/master/bin/prepare_global_zone \
 | bash -s
```

This will install custom services that will load on boot, updating the
image to ensure that users will persist between reboots. By default,
everything except `/usbkey` and `/zones` and `/opt/custom` will reset
between boots, so we have to do some tweaking.

Now run the following:

```bash
curl -k https://raw.github.com/sax/vagrant-smartos-packager/master/bin/prepare_gz_users \
 | bash -s
```

This will create a vagrant user. By default Vagrant expects the vagrant
user and root to have the password set to `vagrant`.

Now clean up some scraps before shutting it down and boxifying:

```bash
curl -k https://raw.github.com/sax/vagrant-smartos-packager/master/bin/cleanup_gz \
 | bash -s
```


### Creating global zone with image imported

If you are creating a box with an image already imported, instead of
the above instructions you can jump straight to:

```bash
curl -k https://raw.github.com/sax/vagrant-smartos-packager/master/bin/prepare_for_lz \
  | bash -s [image_uuid]
```

### Installing sudo

If sudo will be required in the global zone, run the following command:
```bash
curl -k https://raw.github.com/sax/vagrant-smartos-packager/master/bin/install_sudo \
 | bash -s
```

### Creating box

Now stop the VM, and run the following command to load it into Vagrant:

```bash
./bin/boxify
```

**What to name the box?**

* SmartOS-<platform_image>-<image_type>-<image_version>
* SmartOS-20140404T001635Z
* SmartOS-20140404T001635Z-base64-13.4.1

Although these box names are pretty long, they don't have to match the
box name in Vagrant Cloud. As a file name, this encapsulates all the
variables that went into its creation.

Vagrant Cloud links to these boxes can be more terse, and rely on
versioning to abstract away much of this detail.

## Vagrant configurations

#### synced folders

The SmartOS global zone mounts / as a ramdisk with a size of 262M. When
using type `rsync`, to sync the local directory into the global zone,
ensure that it is very lightweight.

In order to use 'rsync' with a larger directory, you'll need to disable
the normal mountpoint and create a new one on a persisted disk.

```ruby
config.vm.synced_folder ".", "/zones/vagrant", type: "rsync"
config.vm.synced_folder ".", "/vagrant", disabled: true
```

Synced folders of type `nfs` will work, pending a pull request on
Vagrant.

## Contributing

When making a pull request, make sure to `/cc @sax` in the description. Otherwise
I don't seem to get notified.
