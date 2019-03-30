CREATE TABLE IF NOT EXISTS student(
id int unsigned not null primary key,
name varchar(32) not null
);

-- CREATE TABLE IF NOT EXISTS… SELECT的行为，先判断表是否存在， 
-- 如果存在，语句就相当于执行insert into select； 
-- 如果不存在，则相当于create table … select。

-- 在数据表存在的时候不创建也不插入重复的数据
-- drop table if exists [tableName];
-- CREATE TABLE IF NOT EXISTS [tableName] SELECT...

create table course
(
    cid int(3),
    cname varchar(20),
    tid int(3)
)

create table teacher
(
    tid int(3),
    tname varchar(20),
    tcid int(3)
)

create table teacherCard
(
    tcid int(3),
    tcdesc varchar(20)
)

-- 多表连接
-- 表的执行顺序，表数据量小的先执行 (笛卡儿积)
-- id相同：从上往下执行
-- id不同: id越大的优先查询
select t.* from teacher t, course c, teacherCard tc
where t.tid = c.tid and
t.tcid = tc.tcid and
c.cname = 'sql';

-- 多表查询 -> 子查询
-- 子查询：先查内层，再查外层
expain select tc.tcdesc from teacherCard tc
where tc.tcid = 
(select t.tcid from teacher t where t.tid=
(select c.tid from course c where c.name='sql'));


-- 子查询+多表
explain select t.tname, tc.tcdesc from teacher t, teacherCard tc
where t.tcid = tc.tcid 
and t.tid = 
(select c.tid from course c where cname='sql');


-- derived
-- 临时表
explain
select cr.cname from 
(select * from course where tid in (1,2)) cr

select cr.cname from
(
(select * from course where tid=1)
union
(select * from course where tid=2)
) cr;


create table test01
(
    tid int(3),
    tname varchar(20)
);

alter table test01 add constraint tid_pk primary key(tid);
alter table test01 add constraint tid_uk unique index(tid);
alter table test01 drop primary key;
insert into test01 values (1, 'a');
commit;

explain select tid from test01
where tid=1

create index tid_index on test01(tid);
alter table test add index tid_index (tid);

drop index index_name on test;
