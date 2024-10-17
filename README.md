# cab

an os wants to be secure and scaled.

to deploy, create a new vfat32 labeled `CABDEPLOYFS`, spam shik into `luks.key` file in usb (that is your keyfile fr), mounts into /etc/nixos against any install medium, create 3 partition on GPT disk that is: EFI, SWAP, ROOT, ./bootstrap /dev/sdX to deploy to that disk.

- [X] looks cool
- [x] luks root encryption
- [ ] secure boot

> [!NOTE]
> on every boot you must have `CABDEPLOYFS` attached
