# mycat
- [官网](http://mycat.org.cn/)
- [GitHub](https://github.com/MyCATApache/Mycat-Server)
- [mycat文档](https://www.yuque.com/ccazhw)
- [mycat1权威指南](https://www.yuque.com/ccazhw/tuacvk)
- []()

- 官网 [Mycat1.x与Mycat2功能对比](https://www.yuque.com/books/share/6606b3b6-3365-4187-94c4-e51116894695/vm9gru)



## mycat 配置

MyCAT目前主要通过配置文件的方式来定义逻辑库和相关配置：

- MYCAT_HOME/conf/schema.xml中定义逻辑库，表、分片节点等内容；

- MYCAT_HOME/conf/rule.xml中定义分片规则；

- MYCAT_HOME/conf/server.xml中定义用户以及系统相关变量，如端口等。

注：以上几个文件的具体配置请参考前面章节中的具体说明.
