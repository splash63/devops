# Домашнее задание к занятию "`Prometheus. Часть 2`" - `Гайченков Евгений`

## Задание 1

![alt text](https://github.com/splash63/devops/blob/main/sflt-01/img/router0.png)

![alt text](https://github.com/splash63/devops/blob/main/sflt-01/img/router1.png)
---

## Задание 2

![alt text](https://github.com/splash63/devops/blob/main/sflt-01/img/master.png)

![alt text](https://github.com/splash63/devops/blob/main/sflt-01/img/stop_nginx.png)

![alt text](https://github.com/splash63/devops/blob/main/sflt-01/img/backup.png)

![alt text](https://github.com/splash63/devops/blob/main/sflt-01/img/start_nginx.png)

![alt text](https://github.com/splash63/devops/blob/main/sflt-01/img/master.png)


# check_webserver.sh
```bash
#!/bin/bash

PORT=80
IP=127.0.0.1
FILE="/var/www/html/index.nginx-debian.html"

nc -z $IP $PORT </dev/null >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Порт $PORT недоступен"
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "Файл $FILE не найден"
    exit 1
fi

echo "Все проверки пройдены"
exit 0
```

# keepalived.conf

```bash
global_defs {
     enable_script_security 10
}

vrrp_script chk_webserver {
    script "/etc/keepalived/check_webserver.sh"
    interval 3
    weight 2
    fall 3
    rise 2
}

vrrp_instance VI_1 {
        state MASTER
        interface eth0
        virtual_router_id 15
        priority 101
        advert_int 1

        virtual_ipaddress {
              192.168.2.59/24
        }

	track_script {
	      chk_webserver

	}
        preempt
}
```