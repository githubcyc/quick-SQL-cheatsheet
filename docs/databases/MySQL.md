## install on Windows

* [MySQL :: Download MySQL Community Server](https://dev.mysql.com/downloads/mysql/5.7.html#downloads)

```bash
# set PATH: D:\MySQL\bin
cd MySQL/
vim my.ini

# init
cd bin
mysqld --defaults-file=D:\MySQL\my.ini --initialize --user=mysql --console
# 安装MySQL服务，以管理员身份运行cmd
mysqld --install MySQL --defaults-file=D:\MySQL\my.ini
# 后台运行 
net start mysql
net stop mysql
# 前台运行
mysqld --defaults-file=D:\MySQL\my.ini 

# 首次连接需要修改root密码
mysql -uroot -p  
mysql> set password=password("dev123");
mysql> flush privileges;  
mysql> exit
```
