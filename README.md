# MySQL High Availability Setup

A production-ready MySQL 8.0 high availability cluster with automatic failover, read/write splitting, connection pooling, and Redis caching.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Application                            │
│               (connect via localhost:3356)                │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                      HAProxy                              │
│                 (port: 3356 / 8081 stats)                │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    ProxySQL                              │
│              (port: 6033 / 6032 admin)                   │
│         Read/Write Split + Connection Pooling             │
└──────┬────────────────────┬───────────────────────────────┘
       │                    │
       ▼                    ▼
┌──────────────┐   ┌──────────────────┐
│   Master    │   │      Slave 1      │
│  MySQL 8.0  │◄──│     MySQL 8.0    │
│  (port:3310)│   │    (port:3307)    │
└──────────────┘   └──────────────────┘
                          │
                          ▼
                   ┌──────────────────┐
                   │      Slave 2      │
                   │     MySQL 8.0    │
                   │    (port:3308)  │
                   └──────────────────┘

        ┌──────────────────┐
        │      Redis        │
        │   (port: 6381)    │
        │    Caching       │
        └──────────────────┘
```

## Components

| Component | Image | Port | Description |
|-----------|-------|------|-------------|
| mysql-master | mysql:8.0 | 3310 | Primary MySQL (read/write) |
| mysql-slave1 | mysql:8.0 | 3307 | Read replica 1 |
| mysql-slave2 | mysql:8.0 | 3308 | Read replica 2 |
| proxysql | proxysql/proxysql | 6033/6032 | Connection pooling + R/W splitting |
| haproxy | haproxy:2.8 | 3356/8081 | Load balancer |
| redis | redis:7-alpine | 6381 | Cache layer |

## Quick Start

```bash
# 1. Copy environment template
cp .env.example .env

# 2. Edit .env with secure passwords
vim .env

# 3. Run setup (auto-configures replication)
./setup-ha.sh

# 4. Or just start services
docker compose up -d
```

## Connection Endpoints

| Service | Host | Port |
|---------|------|------|
| Application | localhost | 3356 |
| ProxySQL (direct) | localhost | 6033 |
| Master (direct) | localhost | 3310 |
| Slave 1 (direct) | localhost | 3307 |
| Slave 2 (direct) | localhost | 3308 |
| Redis | localhost | 6381 |
| HAProxy Stats | localhost | 8081 |
| ProxySQL Admin | localhost | 6032 |

## Scripts

| Script | Usage |
|--------|-------|
| `./setup-ha.sh` | Initial setup with replication config |
| `./status.sh` | Check cluster status |
| `./test-connection.sh` | Test connectivity |
| `./benchmark.sh` | Run performance benchmark |
| `./monitor-realtime.sh` | Real-time monitoring |
| `./monitor-slow.sh` | Slow query monitoring |

## Configuration Files

- `config/master.cnf` - Master MySQL config
- `config/slave.cnf` - Slave MySQL config
- `config/proxysql.cnf` - ProxySQL config
- `config/haproxy.cfg` - HAProxy config
- `config/redis.conf` - Redis config

## Data Storage

MySQL data is stored on `/home/backups-disk2/`:
- `/home/backups-disk2/mysql-master`
- `/home/backups-disk2/mysql-slave1`
- `/home/backups-disk2/mysql-slave2`

## Features

- MySQL 8.0 with row-based replication
- Semi-synchronous replication
- Read/Write splitting via ProxySQL
- Connection pooling (2000 connections per instance)
- Redis caching layer
- HAProxy load balancing
- Automated failover ready
- Monitoring and benchmarking tools