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
