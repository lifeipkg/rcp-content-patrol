# AGENTS.md · rcp-content-patrol

本仓规则。工作区级流程见 `<工作区根>/AGENTS.md`，契约见 `../rcp-contracts`。

## 本仓是什么

四条巡查线之一：内容巡查线。单仓单人维护，改动按标准轨处理；命中"公开契约"（`/check` 请求响应）
或"共享依赖"（`rcp-core`）标签时须独立复核。

## 硬约束

1. **只被网关调用。** 控制器路径、请求体、响应体以契约仓为准；改字段先改 `../rcp-contracts` 再抬钉，禁止先改实现。
2. **决策只用 `rcp-core` 的 `Decision`。** 私造等级或私改分值是 RL-003，语义会与其他三条线不可比。
3. **不直连数据库、不调其他巡查线**（RL-005 / RL-001）。需要跨线信息时，由网关分层编排或在事件里带齐字段。
4. **误杀优先于漏放还是反之，必须写清楚。** 阈值调整要在提交说明里给出标定依据（样本、PR 曲线或反例），不允许凭手感调。
5. **不制造半激活**：接口在、实现空、README 说已支持，三者不一致即算未交付。

## 验证

```bash
mvn -B verify
python ../rcp-contracts/tools/contract_check.py --repo . \
  --contract ../rcp-contracts/contracts/openapi/content-patrol.yaml
```

改判定逻辑时补一条"旧行为应失败"的反向用例；只证明新行为通过不算验证。
