vagrant-smartos-packager
========================

Create Vagrant boxes of the latest SmartOS platform image.

This repository includes scripts to help create SmartOS Vagrant
boxes. The box created will be a Vagrant-capable global zone,
into which local zones can be installed with a TBD vagrant plugin
for managing local zones.

## Dependencies

* VirtualBox

## Usage

Download the latest SmartOS platform image and turn it into
a VirtualBox VM.

```bash
./bin/mksmartvm
```

When the VM spins up in VirtualBox, use the default networking
options. Set the root password to be `vagrant`.

Now log in to the console as root and run the following command.
Unfortunately, the console will not allow for cut and paste, so
it will need to be typed by hand.

```bash
curl -k https://raw.github.com/sax/vagrant-smartos-packager/master/bin/prepare_global_zone | bash -s
```

This will install custom services that will load on boot, updating the
image to ensure that users will persist between reboots. By default,
everything except `/usbkey` and `/zones` and `/opt/custom` will reset
between boots, so we have to do some tweaking.

When the command finishes, reboot the VirtualBox image. Log in again,
and run the following:

```bash
curl -k https://raw.github.com/sax/vagrant-smartos-packager/master/bin/prepare_gz_users | bash -s
```

This will create a vagrant user. By default Vagrant expects the vagrant
user and root to have the password set to `vagrant`.

Now stop the VM, and run the following command to load it into Vagrant:

```bash
./bin/boxify
```

