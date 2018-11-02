1.解压；
2.创建三个节点的data目录， 如data0,data1,data2;
3.在以上三个目录中分别创建文件myid, 并写入内容分别为0,1,2;
4.创建三个节点的配置文件(注意修改其中dataDir,dataLogDir为以上创建目录，注意修改端口)
	如zoo-0.cfg
5.分别启动即可 zkServer.sh  start ./zoo-01.cfg；
6.查看状态 zkServer.sh status ./zoo-01.cfg；