# IAP Refund Simulator

这个目录把 ELA PRO 退款调试拆成两段：

1. App 内一键发起 Apple 官方退款申请
2. 本地模拟后台收到退款回调并打印日志

## App 侧怎么用

1. 用 `Sandbox` 或 `TestFlight + Sandbox Apple ID` 先完成一次订阅购买。
2. 打开 App 的“管理订阅”页。
3. 在 `DEBUG` 环境下进入“退款调试中心”。
4. 点击“一键发起 Apple 退款申请”。
5. Apple 会弹出官方退款申请 sheet。
6. 提交后，回到“查看退款调试日志”确认客户端链路。

### Sandbox 退款结果怎么触发

Apple 测试环境会按退款申请 sheet 的输入自动给出结果：

| 目标场景 | 操作 | App 侧期望 | 后台期望 |
| --- | --- | --- | --- |
| 全额退款通过 | 任意选择一个退款原因并提交 | `Transaction.updates` 收到带 `revocationDate` 的交易，本地临时权益清空 | 收到 `REFUND`，撤销会员权益 |
| 退款被拒 | Issue 选 `Other`，文本框输入 `DECLINE` 后提交 | 不应该撤销当前有效权益 | 收到 `REFUND_DECLINED`，保持会员权益 |
| 部分退款通过 | Issue 选 `Other`，文本框输入 `GRANT_PRORATED` 后提交 | 收到带 `revocationDate` 的交易，本地临时权益清空 | 收到 `REFUND`，记录 `revocationType=REFUND_PRORATED` 和 `revocationPercentage` |

参考 Apple 官方文档：

- https://developer.apple.com/documentation/storekit/testing-refund-requests
- https://developer.apple.com/documentation/appstoreservernotifications/notificationtype
- https://developer.apple.com/documentation/appstoreservernotifications/app-store-server-notifications-v2

## 本地后台回调怎么用

先启动本地监听器：

```bash
bash iap-refund-simulator/run_callback_monitor.sh
```

默认会监听：

```text
http://127.0.0.1:8788/app-store-notifications
```

然后你可以发送本地 mock 回调：

```bash
bash iap-refund-simulator/send_refund_approved_mock.sh
bash iap-refund-simulator/send_refund_declined_mock.sh
bash iap-refund-simulator/send_refund_prorated_mock.sh
```

脚本会把请求打到本地监听器，并把收到的内容写入：

```text
iap-refund-simulator/logs/callback-events.ndjson
```

## 接真实 Apple Sandbox 通知

这个目录里的样例是“解码后的 mock JSON”，方便你们本地联调状态机。  
真实的 `App Store Server Notifications V2` 回调体是：

```json
{
  "signedPayload": "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

如果你们要让 Apple Sandbox 直接回调到本机，需要额外准备一条公网 HTTPS 地址，比如：

1. 测试环境后台地址
2. 或者 ngrok / Cloudflare Tunnel 之类的临时公网隧道

App Store Connect 里需要给 Sandbox 环境单独配置通知 URL；服务端收到通知后，只有在 `signedPayload` 已完成落库或幂等确认后再返回 `200`。如果入口临时不可用，应返回 `40x`/`50x` 让 Apple 重试，恢复后再用 Notification History 补齐缺口。

## 后台建议校验点

1. `notificationType` 是否为 `REFUND` / `REFUND_DECLINED`
2. `environment` 是否为 `Sandbox`
3. `bundleId`、`productId`、`transactionId`、`originalTransactionId`
4. 退款后是否撤销会员权益
5. 部分退款时是否正确记录 `revocationType` / `revocationPercentage`

## 目录结构

```text
iap-refund-simulator/
├── README.md
├── callback_receiver.py
├── send_mock_notification.py
├── run_callback_monitor.sh
├── send_refund_approved_mock.sh
├── send_refund_declined_mock.sh
├── send_refund_prorated_mock.sh
└── samples/
```
