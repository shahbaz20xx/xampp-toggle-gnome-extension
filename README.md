
# XAMPP Toggle

Toggle XAMPP server on/off from the Quick Settings menu without entering password

![Xampp Server On](screenshots/xampp-on.png)
![Xampp Server Off](screenshots/xampp-off.png)

### Install

#### Prerequisite

- Install XAMPP 

#### Using GNOME Extensions website

(Not yet available on the GNOME Extensions website)

#### Installing from source

Clone repo:

```bash
git clone https://github.com/shahbaz20xx/xampp-toggle-gnome-extension && cd xampp-toggle-gnome-extension
```

Install extension:

```bash
./install.sh
```

To delete extension run:

```bash
./uninstall.sh
```

Or manually remove this directory:  
`~/.local/share/gnome-shell/extensions/xampp-toggle@chshahaz108@gmail.com`  
And remove this file:  
`/etc/sudoers.d/xampp-toggle`