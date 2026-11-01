# rcp-content-patrol · 内容巡查线

平台四条巡查线之一，只被 `api-gateway` 调用，**不对外暴露**（红线 RL-002）。

| 项 | 值 |
|---|---|
| 服务名 | `content-patrol` |
| 端口 | `8081` |
| 契约 | `rcp-contracts/contracts/openapi/content-patrol.yaml` |
| 上游 | `api-gateway`（`POST /api/v1/patrol/dispatch` 转发） |
| 依赖 | `rcp-core` 钉版 `v1.0.0` |

## 判定口径

- **判重命中 → INTERCEPT**：正文 SimHash 汉明距离 ≤ 3，或短标题编辑距离 ≤ 4；
- **未命中 → PASS**。
- 业务不对称：岗位重复洗稿的**漏放代价 << 误杀代价**，阈值向 precision 倾斜，宁可放过不可错杀。

## 接口

```
POST /api/v1/patrol/check    # 巡查入口，返回 PatrolVerdict
GET  /api/v1/patrol/shard    # 分片观测（桶倾斜监控）
```

请求/响应结构见契约仓；**本仓不得自行改动字段**，改字段先改契约并抬钉。

## 构建与验证

```bash
mvn -B install -f ../rcp-core/pom.xml -DskipTests   # 首次需先装基座
mvn -B verify                                        # 编译 + 测试
python ../rcp-contracts/tools/contract_check.py \
  --repo . --contract ../rcp-contracts/contracts/openapi/content-patrol.yaml
```

## 边界

- 不直连数据库（红线 RL-005）：需要持久化时经 `dataway`；
- 不调用其他巡查线（红线 RL-001）：跨线协同由网关在 dispatch 层编排；
- 不自定义决策等级（红线 RL-003）：只用 `rcp-core` 的 `Decision`。
