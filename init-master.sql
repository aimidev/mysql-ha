-- Create replication user
CREATE USER 'replicator'@'%' IDENTIFIED BY 'replication_password_here';
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';

-- Create monitoring user for ProxySQL
CREATE USER 'monitor'@'%' IDENTIFIED BY 'monitor';
GRANT USAGE, REPLICATION CLIENT ON *.* TO 'monitor'@'%';

-- Create HAProxy check user
CREATE USER 'haproxy_check'@'%';

FLUSH PRIVILEGES;
