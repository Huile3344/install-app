1.��ѹ��
2.����������rs1;
3.����3����־Ŀ¼������Ŀ¼��
4.�������������ļ�����ע���޸���־Ŀ¼������Ŀ¼���˿ڣ�
5.ʹ�������ļ���������ʵ��bin/mongod --config /home/mongodb/db_rs0/config_rs0/rs0.conf
6.�����һ��ʵ���Ŀͻ��� bin/mongo --port 27011��
7.��ʼ��primary�ڵ㣬�����ڵ㣺
	rs.initiate({_id:'rs1',members:[{_id:1,host:'ip:27011'}]})��
	rs.conf()��
	rs.add("ip:27012")��  //��ӵڶ����ڵ㣻
	rs.addArb("ip:27013")��//��ӵ������ڵ㣻
	rs.status()��//�鿴״̬
8.�˳���һ��ʵ���Ŀͻ��ˣ����rs1��������

9.�ظ����� ���rs2��������

10.������̨���÷�������ʹ�������ļ�����ע���޸Ķ˿ں�Ŀ¼��
	bin/mongod --config /home/mongodb/cfgserver/cfgserver.conf
11.��¼���÷�����bin/mongo --port 27021;
12.��ʼ�����÷�������
rs.initiate({_id:"cfgset",configsvr:true, members:[{_id:1,host:"ip:27021"},{_id:2,host:"ip:27022"},{_id:3,host:"ip:27023"}]})

13.����mongos
	bin/mongos --config /home/mongodb/mongos/cfg_mongos.conf;
14.����mongos��bin/mongo --port 27031
15.���������Ⱥ��Ƭ��27013��27016Ϊ�ٲýڵ������ݲ����
	sh.addShard("rs1/ip:27011,ip:27012")
	sh.addShard("rs2/ip:27014,ip:27015")
16.��ɣ��鿴��Ƭ״̬��sh.status();