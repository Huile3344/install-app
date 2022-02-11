# mysql 知识点

单机知识点
- 红黑树、B树、B+树，为什么mysql使用B+树，而HashMap使用链表和红黑树
- 索引类型
- sql 调优，explain 列
- mvcc
- 缓存页、排序缓存等缓存
- innodb 和 myisam 等其他引擎优劣和适用场景
集群知识点  
- binlog、redolog、undolog，及实现原理
- binlog、redolog 二阶段提交  
- mysql 一致性实现原理
- mysql 原子性实现原理
- 中继日志
- 主从复制搭建
- 双主双从，互为主备搭建
- 主从复制延迟问题
故障排查
- information_schema 常用表说明
- 死锁
- 锁超时
其他常见问题
- mysql账号无法登录

# mysql 常用定位问题脚本
## 基本概念

### processlist 表的解释

processlist命令的输出结果显示了有哪些线程在运行，可以帮助识别出有问题的查询语句，两种方式使用这个命令。如果有SUPER权限，则可以看到全部的线程，否则，只能看到自己发起的线程(这是指，当前对应的MySQL帐户运行的线程)。

#### processlist

下面对 `processlist` 表的每个字段进行解释：

| 字段名称 | 说明                                                         |
| -------- | ------------------------------------------------------------ |
| ID       | 会话id，在mysql层面查杀使用的                                |
| USER     | 访问的用户，这个命令就只显示你权限范围内的sql语句            |
| HOST     | 显示这个语句是从哪个ip的哪个端口上发出的                     |
| DB       | 显示这个进程目前连接的是哪个数据库                           |
| COMMAND  | 显示当前连接的执行的命令                                     |
| TIME     | 此这个状态持续的时间，单位是秒，如果后面有语句，要小心了，说明该语句有问题 |
| STATE    | 显示使用当前连接的sql语句的状态，很重要的列，后续会有所有的状态的描述，请注意，state只是语句执行中的某一个状态，一个sql语句，已查询为例，可能需要经过copying to tmp table，Sorting result，Sending data等状态才可以完成 |
| INFO     | 显示这个sql语句，因为长度有限，所以长的sql语句就显示不全，但是一个判断问题语句的重要依据 |



### Innodb_* 表的解释

Mysql`的`InnoDB`存储引擎是支持事务的，事务开启后没有被主动`Commit`。导致该资源被长期占用，其他事务在抢占该资源时，因上一个事务的锁而导致抢占失败！因此出现 `Lock wait timeout exceeded

下面几张表是innodb的事务和锁的信息表，理解这些表就能很好的定位问题。

- `innodb_trx`  当前运行的所有事务
- `innodb_locks`  当前出现的锁
- `innodb_lock_waits`  锁等待的对应关系



#### innodb_trx

下面对 `innodb_trx` 表的每个字段进行解释：

| 字段名称 | 说明 |
| -------- | ---- |
| trx_id | 事务ID |
| trx_state | 事务状态，有以下几种状态：RUNNING、LOCK WAIT、ROLLING BACK 和 COMMITTING |
| trx_started | 事务开始时间 |
| trx_requested_lock_id | 事务当前正在等待锁的标识，可以和 INNODB_LOCKS 表 JOIN 以得到更多详细信息 |
| trx_wait_started | 事务开始等待的时间 |
| trx_weight | 事务的权重 |
| trx_mysql_thread_id | 事务线程 ID，可以和 PROCESSLIST 表 JOIN |
| trx_query | 事务正在执行的 SQL 语句 |
| trx_operation_state | 事务当前操作状态 |
| trx_tables_in_use | 当前事务执行的 SQL 中使用的表的个数 |
| trx_tables_locked | 当前执行 SQL 的行锁数量 |
| trx_lock_structs | 事务保留的锁数量 |
| trx_lock_memory_bytes | 事务锁住的内存大小，单位为 BYTES |
| trx_rows_locked | 事务锁住的记录数。包含标记为 DELETED，并且已经保存到磁盘但对事务不可见的行 |
| trx_rows_modified | 事务更改的行数 |
| trx_concurrency_tickets | 事务并发票数 |
| trx_isolation_level | 当前事务的隔离级别 |
| trx_unique_checks | 是否打开唯一性检查的标识 |
| trx_foreign_key_checks | 是否打开外键检查的标识 |
| trx_last_foreign_key_error | 最后一次的外键错误信息 |
| trx_adaptive_hash_latched | 自适应散列索引是否被当前事务锁住的标识 |
| trx_adaptive_hash_timeout | 是否立刻放弃为自适应散列索引搜索 LATCH 的标识 |



#### innodb_locks

下面对 `innodb_locks` 表的每个字段进行解释：

| 字段名称 | 说明 |
| -------- | ---- |
| lock_id | 锁 ID |
| lock_trx_id | 拥有锁的事务 ID。可以和 INNODB_TRX 表 JOIN 得到事务的详细信息 |
| lock_mode | 锁的模式。有如下锁类型：<br/>       行级锁包括：S、X、IS、IX，分别代表：共享锁、排它锁、意向共享锁、意向排它锁。<br/>       表级锁包括：S_GAP、X_GAP、IS_GAP、IX_GAP 和 AUTO_INC，分别代表共享间隙锁、排它间隙锁、意向共享间隙锁、意向排它间隙锁和自动递增锁 |
| lock_type | 锁的类型。RECORD 代表行级锁，TABLE 代表表级锁 |
| lock_table | 被锁定的或者包含锁定记录的表的名称 |
| lock_index | 当 LOCK_TYPE=’RECORD’ 时，表示索引的名称；否则为 NULL |
| lock_space | 当 LOCK_TYPE=’RECORD’ 时，表示锁定行的表空间 ID；否则为 NULL |
| lock_page | 当 LOCK_TYPE=’RECORD’ 时，表示锁定行的页号；否则为 NULL |
| lock_rec | 当 LOCK_TYPE=’RECORD’ 时，表示一堆页面中锁定行的数量，亦即被锁定的记录号；否则为 NULL |
| lock_data | 当 LOCK_TYPE=’RECORD’ 时，表示锁定行的主键；否则为NULL |



#### innodb_lock_waits

下面对 `innodb_lock_waits` 表的每个字段进行解释：

| 字段名称 | 说明 |
| -------- | ---- |
| requesting_trx_id | 请求事务的 ID |
| requested_lock_id | 事务所等待的锁定的 ID。可以和 INNODB_LOCKS 表 JOIN |
| blocking_trx_id | 阻塞事务的 ID |
| blocking_lock_id | 某一事务的锁的 ID，该事务阻塞了另一事务的运行。可以和 INNODB_LOCKS 表 JOIN |





## 死锁

- 死锁查询（查询 正在执行的事务）

  ```sql
  SELECT t.trx_mysql_thread_id FROM INFORMATION_SCHEMA.INNODB_TRX t;
  ```

- 杀死死锁线程, t.trx_mysql_thread_id 字段值

  ```sql
  kill 进程ID;
  ```

- 死锁日志查询

  ```sql
  show engine innodb status;
  ```

- 查看正在锁的事务

  ```sql
  SELECT * FROM INFORMATION_SCHEMA.INNODB_LOCKS;
  ```

- 查看等待锁的事务

  ```sql
  SELECT * FROM INFORMATION_SCHEMA.INNODB_LOCK_WAITS;
  ```

- 查看执行的线程

  ```sql
  show processlist;
  ```

- 查看当前数据库执行中的慢sql

  ```sql
  select * from information_schema.processlist where command != 'sleep';
  ```

- 查看慢sql

  ```sql
  select * from mysql.slow_log
  ```

- 确认慢sql日志表是否损坏(有报错就损坏了)

  ```sql
  SELECT CONVERT(sql_text USING utf8),rows_examined FROM mysql.slow_log order by rows_examined desc
  ```

- 查看表数据和索引占用空间大小

  ```sql
  select t.TABLE_NAME 表名, 
  case when t.DATA_LENGTH>1024*1024*1024 then CONCAT(t.DATA_LENGTH/1024/1024/1024,' GB') when t.DATA_LENGTH>1024*1024 then CONCAT(t.DATA_LENGTH/1024/1024,' MB') when t.DATA_LENGTH>1024 then CONCAT(t.DATA_LENGTH/1024,' KB') else CONCAT(t.DATA_LENGTH,' B') end 数据, 
  case when t.INDEX_LENGTH>1024*1024*1024 then CONCAT(t.INDEX_LENGTH/1024/1024/1024,' GB') when t.INDEX_LENGTH>1024*1024 then CONCAT(t.INDEX_LENGTH/1024/1024,' MB') when t.INDEX_LENGTH>1024 then CONCAT(t.INDEX_LENGTH/1024,' KB') else CONCAT(t.INDEX_LENGTH,' B') end 索引, 
  t.TABLE_ROWS 行数
  from information_schema.tables t
  where table_schema='locals_dispatch'
  -- 剔除备份表
  and INSTR(t.TABLE_NAME,'bak')<=0 and INSTR(t.TABLE_NAME,'copy')<=0
  ```



## 锁等待超时 

MySQL事务锁等待超时 lock wait timeout exceeded; try restarting transaction

### 常见问题出现的场景

1. 在消息队列处理消息时，同一事务内先后对同一条数据进行了插入和更新操作;
2. 多台服务器操作同一数据库；
3. 瞬时出现高并发现象；

导致数据更新或新增后数据经常自动回滚；表操作总报 `lock wait timeout exceeded` 并长时间无反应



### 问题剖析

#### 原因分析

`MySql lock wait timeout exceeded` 这个问题我相信大家对它并不陌生，但是有很多人对它产生的原因以及处理吃的不是特别透，很多情况都是交给DBA去定位和处理问题，接下来我们就针对这个问题来展开讨论：

Mysql造成锁的情况有很多，下面我们就列举一些情况：

1. 执行DML操作没有commit，再执行删除操作就会锁表。
2. 在同一事务内先后对同一条数据进行插入和更新操作。
3. 表索引设计不当，导致数据库出现死锁。
4. 长事务，阻塞DDL，继而阻塞所有同表的后续操作。

但是要区分的是`Lock wait timeout exceeded`与`Dead Lock`是不一样。

- `Lock wait timeout exceeded`：后提交的事务等待前面处理的事务释放锁，但是在等待的时候超过了mysql的锁等待时间，就会引发这个异常。
- `Dead Lock`：两个事务互相等待对方释放相同资源的锁，从而造成的死循环，就会引发这个异常。

还有一个要注意的是`innodb_lock_wait_timeout`与`lock_wait_timeout`也是不一样的。

- `innodb_lock_wait_timeout`：innodb的dml操作的行级锁的等待时间
- `lock_wait_timeout`：数据结构ddl操作的锁的等待时间

那么如何查看innodb_lock_wait_timeout的具体值：

```sql
SHOW VARIABLES LIKE 'innodb_lock_wait_timeout';
```

如何修改innode lock wait timeout的值，参数修改的范围有Session和Global，并且支持动态修改，可以有两种方法修改：

方法一：

通过下面语句修改

```sql
set innodb_lock_wait_timeout=100;
set global innodb_lock_wait_timeout=100;
```

*ps. 注意global的修改对当前线程是不生效的，只有建立新的连接才生效。*

方法二：

修改参数文件`/etc/my.cnf` `innodb_lock_wait_timeout = 50`

*ps. `innodb_lock_wait_timeout`指的是事务等待获取资源等待的最长时间，超过这个时间还未分配到资源则会返回应用失败； 当锁等待超过设置时间的时候，就会报如下的错误；`ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction`。其参数的时间单位是秒，最小可设置为1s(一般不会设置得这么小)，最大可设置1073741824秒，默认安装时这个值是50s(默认参数设置)。*

查看其他超时配置:

```
SHOW VARIABLES LIKE '%timeout%';
```

ps: 修改方式类似 innodb_lock_wait_timeout 



#### 原因总结

- 在高并发的情况下，Spring事物造成数据库死锁，后续操作超时抛出异常。
- Mysql数据库采用InnoDB模式，默认参数:innodb_lock_wait_timeout设置锁等待的时间是50s，一旦数据库锁超过这个时间就会报错。



#### 解决方法

- 应急方法：`show full processlist;` `kill`掉出现问题的进程。 *ps.有的时候通过processlist是看不出哪里有锁等待的，当两个事务都在commit阶段是无法体现在processlist上*
- 根治方法：`select * from information_schema.innodb_trx;`查看有是哪些事务占据了表资源。 *ps.通过这个办法就需要对innodb有一些了解才好处理*
- 增加锁等待时间，即增大下面配置项参数值，单位为秒（s） `innodb_lock_wait_timeout=500`
- 优化存储过程,事务避免过长时间的等待

说起来很简单找到它杀掉它就搞定了，但是实际上并没有想象的这么简单，当问题出现要分析问题的原因，通过原因定位业务代码可能某些地方实现的有问题，从而来避免今后遇到同样的问题。



### 真实事件定位处理

#### 背景

公司针对现有政务交易系统的多个不通业务，需要针对其 `招投开评定` 共性点过程进行抽象，开发一个中台服务(项目服务中心)处理这部分逻辑，替换个业务系统各自为政，无法共用，重复开发，开发周期长问题。处理方案是在不大改业务系统的情况下实现这么一个中台服务，因此采用mycat作为中间件，基于分库分表的思想汇总业务系统的物理库(因为部分表共性很大)，形成一个mycat的逻辑数据库供项目服务中心的使用，所有的增删改由业务方调用中台服务接口完成，业务方查询仍然是自己读物理表。



#### 问题显现

在中台服务与业务系统对接联调过程中，业务方调用中台服务的修改项目标的接口时，中台服务突然出现了 `lock wait timeout exceeded; try restarting transaction` 



#### 问题过程分析

1. 由于中台服务这是项目刚起步阶段，针对修改接口并未做太多业务处理，几乎等价于直接写数据库了
2. 前期测试已经使用jmeter串联测试过中台服务的接口，测试中并未出现这类问题
3. 难道是 mycat 这个中间件有异常



#### 问题复现和分析

异常出现在中台服务，那么必然就需要先去中台服务定位。

1. 先单独用postman/jmeter直接调用接口测试，确认问题能否复现。测试并未发现异常，且相应时间也是在几毫秒内就完成

   

2. 但是改为业务方调用再次测试，发现问题仍然存在，且每次在业务方的特定流程点就一定会触发这个问题。难道是和流程关联的，只要调用中台服务特定几个接口，且按一定顺序就可以触发，中台服务本身业务处理有问题？或者仅是mysql锁超时时间问题？再不济就是mycat这个中间件有问题了？

   

3. 难道只是锁超时时间太短导致的？考虑修改锁超时时间

   查看mysql锁超时配置

   ```sql
   SHOW VARIABLES LIKE 'innodb_lock_wait_timeout';
   ```

   发现锁超时时间是50s，先暂时增大一倍，改成100s

   ```
   set innodb_lock_wait_timeout=100;
   set global innodb_lock_wait_timeout=100;
   ```

   重启一下mycat，保证mycat使用的连接池中的所有mysql连接配置已生效

   让业务方再次测试，发现调用到修改接口(触发点，执行update语句时)仍然等待，耗时很久大概60多秒，但是这次中台服务总算没报错了。但是这个耗时也太久了，就这么个小接口。没过一会儿业务方告知调用失败了，他们的feignclient超时了，大家都知道默认feignclient超时是60s的，怎么他们一超时我们这边就处理完了？

   

4. 实时查看在mysql执行修改语句等待期间，mysql的线程和锁等情况是怎样的

   让业务方再试触发复现，并在mysql执行如下语句，进行观察(关于各表信息，在本文档前面有说明)

   

   查看事务信息

   ```sql
   select * from information_schema.INNODB_TRX it ;
   ```

   输出结果:

   |trx_id|trx_state|trx_started        |trx_requested_lock_id|trx_wait_started   |trx_weight|trx_mysql_thread_id|trx_query                                                                                                                                                                                                                                                      |trx_operation_state|trx_tables_in_use|trx_tables_locked|trx_lock_structs|trx_lock_memory_bytes|trx_rows_locked|trx_rows_modified|trx_concurrency_tickets|trx_isolation_level|trx_unique_checks|trx_foreign_key_checks|trx_last_foreign_key_error|trx_adaptive_hash_latched|trx_adaptive_hash_timeout|trx_is_read_only|trx_autocommit_non_locking|
   |------ |--------- |------------------- |--------------------- |------------------- |---------- |------------------- |--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |------------------- |----------------- |----------------- |---------------- |--------------------- |--------------- |----------------- |----------------------- |------------------- |----------------- |---------------------- |-------------------------- |------------------------- |------------------------- |---------------- |--------------------------|
   |52096 |LOCK WAIT|2022-01-08 10:28:01|52096:867:3:68       |2022-01-08 10:28:01|         2|              49650|update pub_t_package set BASE_STATUS=null, before_id=null, CREATE_TIME='2022-01-06 20:21:24.986', CREATOR_ID='1', CREATOR_NAME='测试', DELETE_FLAG=0, UPDATE_TIME='2022-01-08 10:28:00.61', UPDATOR_ID='1', UPDATOR_NAME='测试', APPROVAL_STATUS='PASSED', BUDGET_A|starting index read|                1|                1|               2|                 1136|              1|                0|                      0|REPEATABLE READ    |                1|                     1|                          |                        0|                        0|               0|                         0|
   |52093 |RUNNING  |2022-01-08 10:27:26|                     |                   |         3|              84705|                                                                                                                                                                                                                                                               |                   |                0|                1|               2|                 1136|             29|                1|                      0|REPEATABLE READ    |                1|                     1|                          |                        0|                        0|               0|                         0|

   可以看到，当前是有两个事务的，中台服务的事务是在 `LOCK WAIT` 状态，另一个在RUNNING，但是并没有显示相关语句

   

   查看锁信息

   ```sql
   select * from information_schema.INNODB_LOCKS il ;
   ```

   输出结果：

   | lock_id        | lock_trx_id | lock_mode | lock_type | lock_table             | lock_index | lock_space | lock_page | lock_rec | lock_data                          |
   | -------------- | ----------- | --------- | --------- | ---------------------- | ---------- | ---------- | --------- | -------- | ---------------------------------- |
   | 52096:867:3:68 | 52096       | X         | RECORD    | `tdkc`.`pub_t_package` | PRIMARY    | 867        | 3         | 68       | '402c819f7e2d892a017e2e035e010008' |
   | 52093:867:3:68 | 52093       | X         | RECORD    | `tdkc`.`pub_t_package` | PRIMARY    | 867        | 3         | 68       | '402c819f7e2d892a017e2e035e010008' |

   可以看到要修改的数据是被 `X` 行锁给锁了，什么鬼，怎么还有另外一个事务锁了这条数据

   

   查看锁等待信息

   ```sql
   select * from information_schema.INNODB_LOCK_WAITS ilw ;
   ```
   输出结果:

   | requesting_trx_id|requested_lock_id|blocking_trx_id|blocking_lock_id|
   | ----------------- |----------------- |--------------- |---------------- |
   | 52096            |52096:867:3:68   |52093          |52093:867:3:68  |

   确实只有中台服务的事务在等待锁

   

   查看进程信息

   ```sql
   select * from information_schema.processlist where command != 'sleep';
   ```
   输出结果：

   |ID   |USER|HOST            |DB         |COMMAND|TIME|STATE    |INFO                                                                                                                                                                                                                                                           |
   |----- |---- |---------------- |----------- |------- |---- |--------- |--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
   |83589|root|10.244.0.1:36146|project_dev|Query  |   0|executing|select * from information_schema.processlist where command != 'sleep'¶LIMIT 0, 200                                                                                                                                                                             |
   |49650|root|10.244.0.1:44098|xxx       |Query  |   5|updating |update pub_t_package set BASE_STATUS=null, before_id=null, CREATE_TIME='2022-01-06 20:21:24.986', CREATOR_ID='1', CREATOR_NAME='测试', DELETE_FLAG=0, UPDATE_TIME='2022-01-08 10:28:00.61', UPDATOR_ID='1', UPDATOR_NAME='测试', APPROVAL_STATUS='PASSED', BUDGET_A|

   执行中的线程只有服务中台的线程

   另外一个事务的线程是从哪里来的，不是只有中台服务的服务在改数据吗？难道是mycat中间件有问题；要不然就是业务方也在改，不可能的啊，设计方案不是已经说了不能业务方不能改数据，只能查了啊。杀那个线程看看？
   
   
   
    其他辅助查询语句
   
   ```
   -- 查看死锁等等信息
   show engine innodb status ;
   -- 查看线程信息
   show processlist ;
   show full processlist ;
   -- 杀死线程
   kill id;
   ```
   



#### 确定原因

mycat中间件应该没那么脆弱，要是有这种问题应该老早就有人提出来了。于是找业务方了解了一下，最终确实发现业务方有调用update操作，同时又调用了中台服务的修改逻辑，同时又等待中台服务修改完成后才提交事务，导致了一个逻辑死锁问题，由中台服务锁等待超时报出问题（就是第二种场景）。后续问题只要业务方规范即可，根本还是业务方任务急，很多内容为按规范处理导致的。



#### 解决方法

业务方剔除相关的所有增删改逻辑
