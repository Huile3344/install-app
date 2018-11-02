// 所有需要在mongos中额外执行的分片脚本写在此脚本文件中
// MongoDB分片是针对集合的，要想使集合支持分片，首先需要使其数据库支持分片，为数据库 test 启动分片 根据需要将 test 改为真正的数据库名：
sh.enableSharding("test")
// 切换到具体数据库
use test
// 为分片字段建立索引，同时为集合指定片键：
db.erpListing.createIndex({company_id:1, sku:1}) // 创建索引
sh.shardCollection("test.erpListing",{company_id:1, sku:1}) //启用集合分片，为其指定片键
// 再次查看分片集群状态：
sh.status()
