## MySQL version

* 主流版本 5.x
  * 5.0-5.1:早期产品的延续
  * 5.4-5.x： 整合了三方公司的新存储引擎(推荐5.5)
  * 安装方式
    * yum install mysql-server
    * tar.gz
    * rpm -ivh <pkg name>

```bash
yum -y remove xxx
rpm -ivh MySQL-client

// set password for root
/usr/bin/mysqladmin -u root password `new psw`

// check 
mysqladmin --version
service mysql start/restart 
service mysql stop

// login
mysql -u root -p 

// encode -> utf8
show variables like '%char%';

vi /etc/my.cnf
[mysql]
default-character-set=utf8
[client]
default-character-set=utf8

[mysqld]
character_set_server=utf8
character_set_client=utf8
collation_server=utf8_general_ci

// datadir
ps -ef | grep mysql
datadir=/var/lib/mysql

cd /var/lib/mysql
ll
```

* /var/lib/mysql/mysql.sock不存在，mysql未启动
  * 手动启动: /erc.init.d/mysql start
  * 开机启动: chkconfig mysql on/off
  * 检查开机是否启动: ntsysv

* 核心目录
  * 安装目录/var/lib/mysql
  * 配置文件 /usr/share/mysql
  * 命令目录 /usr/bin (mysqladmin、mysqldump)

* 默认配置文件
  * 5.5 /etc/my.cnf
  * 5.6 /etc/mysql-default.cnf

```bash
cp /usr/share/mysql/my-huge.cnf /etc/my.cnf
```

## Mysql server

* 连接层
* 服务层
  * select
  * SQL Query Optimizer
* engine
  * InnoDB 行锁，事务优先 (适合高并发操作)
  * MyISAM 表锁，性能优先
* 存储层
  * 

```bash
show engines \G
show variables like '%storage_engine%'
;

// 指定数据库引擎
mysql> create table tb(
    id int(4) auto_increment,
    name varchar(10),
    primary key (id)
) ENGINE=MyISAM AUTO_INCREMENT=1
DEFAULT_CHARSET=utf8;
```

## SQL 优化


## in/ not in/ exists /not exists

* SQL 解析
```bash
select distinct from .. join on where group by having
order by limit n
```

* index 
  * :star: 数据结构 B+tree,数据全部放于叶节点 
  * 索引列(小的左，大的右)

* 优势
  *  提高查询效率，降低IO使用率
  *  降低CPU使用率(order by age desc) B+tree
* 缺点
  * 索引本身很大，占空间 
  * 索引不是所有情况均适用
    * 数据条数少
    * 频繁更新的字段
  * 索引会降低增删改的效率

* 分类
  * 单值索引
  * 唯一索引 unique
  * 复合索引, 多列

```sql
// method 1
create index dep_index on tb(dep);

create unique index name_index on tb(name);

create index dep_name_index on tb(dep, name);

// method 2
alter table tb add index dep_index(dep)
alter table tb add unique index name_index(name)
alter table tb add index dep_name_index(dep, name)

// primary key (不能为null)
// unique index (可null)

drop index index_name on table_name;

// query index
show index from tb \G
DESC tb;

// engine 
alter table test01 ENGINE=InnoDB
```

* SQL 性能分析
  * 分析SQL执行计划 explain
  * MySQL查询优化会干扰我们的优化

```sql
explain select * from tb;
```

* select_type
  * PRIMARY：主查询
  * SUBQUERY：子查询
  * simple 简单查询（不包含子查询，union）
  * derived 衍生查询（使用临时表）
    * from 子查询中只有一张表
    * from 子查询中， 如果有 table1 union table2, table1 是衍生的,table2 是union
  * union result

* type 索引类型
  * type优化前提，有index
  * system>const>eq_ref>ref>range>index>all
  * system是const类型的特例，当查询的表只有一行的情况下，使用system
  * 实际上能达到ref>range

  * const: 仅能查到**一条**数据的SQL,用于pk或者unique索引
    * 通常情况下，如果将一个`主键`放置到where后面作为条件查询，mysql优化器就能把这次查询优化转化为一个常量。
  * eq_ref 唯一性索引(unique index) equal
    * explain select a.id from age a, big b where a.id = b.id
  * ref 非唯一性索引，name是索引列
    * (select * from test where name='t1') res>=0
  * range 检索指定范围的行, where (between and/ <>= ) 
    * in 可能失效 --> all

  * index 查询全部索引中的数据
    * select tid from test; tid -> index
  * all 查询全部表中的数据
    * select cid from test; cid is not INDEX

* key_len
  * alter table test add column name char(20) not null default ''
    * select * from test where name = ''
    * utf8:一个字符占3 byte
    * gbk: 2 byte
    * latin: 1 byte
  * alter table test add column name1 char(20);
    * ley_len=61，1个byte标识name1可为null
  * 复合索引 alter table test add index name_name1_index (name, name1);
    * select * from test where name = ''  len=60
    * select * from test where name1 = '' len=121
  * alter table test add column name2 varchar(20) 
    * alter table add index name2_index (name2);
    * len=63=20*3+1(null)+2(var)

* ref

```sql
explain select tid from test01
where tid=1
```


## Refer

* [mysql 执行计划type类型及sql优化原则](https://blog.csdn.net/q936889811/article/details/72576182)
* :star:[MySQL :: MySQL 5.5 Reference Manual :: 8 Optimization](https://dev.mysql.com/doc/refman/5.5/en/optimization.html)
* [sql optimization](https://blog.csdn.net/jie_liang/article/details/77340905)
