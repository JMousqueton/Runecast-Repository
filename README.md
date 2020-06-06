# Welcome to Runecast-Repository 👋
![Version](https://img.shields.io/badge/version-3.0-blue.svg?cacheSeconds=2592000)
[![Documentation](https://img.shields.io/badge/documentation-yes-brightgreen.svg)](https://www.julienmousqueton.fr/creer-son-repository-runecast-analyzer)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/JMousqueton/Runecast-Repository/blob/master/LICENSE)
[![Twitter: JMousqueton](https://img.shields.io/twitter/follow/JMousqueton.svg?style=social)](https://twitter.com/JMousqueton)

> Script to host your own repository for [Runecast Analyzer](https://www.runecast.com) on Ubuntu using nginx

### 🏠 [Homepage](https://www.runecast.com)

## :electric_plug: Install

```sh
curl  https://raw.githubusercontent.com/JMousqueton/Runecast-Repository/master/createRepo.sh -o createRepo.sh
chmod u+x createRepo.sh
curl  https://raw.githubusercontent.com/JMousqueton/Runecast-Repository/master/RunecastUpdate.conf -o /etc/RunecastUpdate.conf
```

Edit /etc/RunecastUpdate.conf

```sh
vi /etc/RunecastUpdate.conf
```

## :pencil2: Usage

```sh
./createRepo.sh
```

## :blue_book: Documentation

-   Installation steps

1.  Install nginx apt-mirror and certbot
2.  Modify mirror.list
3.  Create a vhost config file for nginx
4.  Create SSL Certificat (optional)
5.  Create a crontab file
7.  Modify the configuration of your [Runecast Appliance](https://www.runecast.com)

-   Documentation in French 🇫🇷 is available on [my blog](https://www.julienmousqueton.fr/creer-son-repository-runecast-analyzer)

## :white_check_mark: Test

-   Tested on Ubuntu 18.04 server

## Author

👤 **Julien Mousqueton**

*   Website: [https://www.julienmousqueton.fr](https://www.julienmousqueton.fr)
*   Twitter: [@JMousqueton](https://twitter.com/JMousqueton)
*   Github: [@JMousqueton](https://github.com/jmousqueton)
*   LinkedIn: [@julienmousqueton](https://linkedin.com/in/julienmousqueton)

## 🤝 Contributing

Contributions, issues and feature requests are welcome!

Feel free to check [issues page](https://github.com/JMousqueton/Runecast-Repository/issues). You can also take a look at the [contributing guide](https://github.com/JMousqueton/Runecast-Repository/blob/master/CONTRIBUTING.md).

## Todo

-   Add a configuration file and remove variables in scripts

## Show your support

Give a ⭐️ if this project helped you!

## 📝 License

Copyright © 2020 [Julien Mousqueton](https://github.com/JMousqueton).

This project is [MIT](https://github.com/JMousqueton/Runecast-Repository/blob/master/LICENSE) licensed.

***
