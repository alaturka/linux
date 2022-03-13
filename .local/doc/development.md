Development
==========

### Develop and/or play locally with boot and install

Use the `play` script in default mode.

- Enter Vagrant box

  ```sh
  vagrant box destroy -f # Reset box
  vagrant up
  vagrant ssh
  ```

- Bootstrap

  ```ps1
  sudo .local/bin/play boot
  ```

- Install

  ```ps1
  sudo .local/bin/play install
  ```

### Test production

Add `-mode production` switch to the `play` invocations.

### Update sources

Make sure that https://github.com/alaturka/ellipses has been installed:

```sh
gem install ellipses
```

After modifications:

```sh
src update
```
