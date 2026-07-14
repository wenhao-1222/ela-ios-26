import fs from "node:fs/promises";
import { SpreadsheetFile, Workbook } from "@oai/artifact-tool";

const outputDir = "/Users/lns2/Desktop/lnsapp-ios/outputs/abc_test_acceptance";
const outputPath = `${outputDir}/ABC_Test_分组验收用例.xlsx`;

const statusValues = ["待测", "通过", "未通过", "阻塞", "不适用"];

const cases = [
  ["TC-001", "老版本基础", "老用户", "老版本", "已登录", "register_time < timeA", "空", "无", "config/get", "老用户在老版本已登录状态打开 App，触发 config/get。", "返回 A；后台写入或保持 user_group=A；不调用 URL_user_group_init/msg。", "P0", "待测", "", ""],
  ["TC-002", "老版本基础", "老用户", "老版本", "已登录", "register_time < timeA", "A", "无", "config/get", "老用户在老版本已登录状态打开 App。", "返回 A；user_group 保持 A。", "P0", "待测", "", ""],
  ["TC-003", "老版本登录", "老用户", "老版本", "未登录后登录", "register_time < timeA", "空", "无", "config/get", "老用户先未登录打开老版本，再完成登录。", "登录后通过 config/get 返回 A；后台写入 A。", "P0", "待测", "", ""],
  ["TC-004", "老版本未登录", "未知用户", "老版本", "未登录", "无用户注册时间", "无", "无", "config/get", "未登录状态打开老版本。", "不调用 URL_user_group_init/msg；config/get 返回老版本兼容配置；不能出现 B/C 用户实验能力。", "P1", "待测", "", ""],
  ["TC-005", "老版本新注册", "新用户", "老版本", "注册/登录", "register_time >= timeA", "空", "无", "config/get", "用户在 timeA 后使用老版本注册或登录。", "因老版本没有 ABC 接口，需按兼容策略处理；建议返回 A 或默认兼容组，不能依赖 URL_user_group_init/msg。", "P0", "待测", "", "需产品/后台确认老版本新注册用户是否统一 A。"],
  ["TC-006", "新版本老用户", "老用户", "新版本", "已登录", "register_time < timeA", "空", "无", "config/get", "老用户已登录状态启动新版本。", "返回 A；后台写入 user_group=A。", "P0", "待测", "", ""],
  ["TC-007", "新版本老用户", "老用户", "新版本", "已登录", "register_time < timeA", "A", "无", "config/get", "老用户已登录状态启动新版本。", "返回 A；user_group 保持 A。", "P0", "待测", "", ""],
  ["TC-008", "异常数据纠正", "老用户", "新版本", "已登录", "register_time < timeA", "B/C", "无", "config/get 或 URL_user_group_msg", "构造老用户 user_group 已异常为 B 或 C 后启动新版本。", "建议后台纠正并返回 A；至少最终体验必须为 A。", "P0", "待测", "", "确认后台是否允许覆盖脏数据。"],
  ["TC-009", "新版本未登录初始化", "老用户但未识别", "新版本", "未登录", "无用户注册时间", "无", "无", "URL_user_group_init", "老用户未登录状态启动新版本。", "可按 deviceId 生成临时 A/B/C；该值不能作为登录后的最终用户组。", "P1", "待测", "", ""],
  ["TC-010", "新版本老用户绑定", "老用户", "新版本", "未登录后登录", "register_time < timeA", "空", "B/C", "URL_user_group_msg", "未登录 init 得到 B 或 C，随后登录老账号。", "后台按注册时间识别老用户，返回 A，并写入 user_group=A。", "P0", "待测", "", ""],
  ["TC-011", "新版本老用户绑定", "老用户", "新版本", "未登录后登录", "register_time < timeA", "空", "A", "URL_user_group_msg", "未登录 init 得到 A，随后登录老账号。", "返回 A，并写入 user_group=A。", "P0", "待测", "", ""],
  ["TC-012", "新版本老用户绑定", "老用户", "新版本", "未登录后登录", "register_time < timeA", "A", "任意", "URL_user_group_msg", "已有 user_group=A 的老用户登录新版本。", "返回 A；不重新分组。", "P0", "待测", "", ""],
  ["TC-013", "多设备一致性", "老用户", "新版本", "多设备登录", "register_time < timeA", "空或 A", "设备1=B，设备2=C", "URL_user_group_msg", "同一老用户分别在两台设备登录。", "两台设备最终均返回 A；用户表最终为 A。", "P0", "待测", "", ""],
  ["TC-014", "新用户初始化", "新用户", "新版本", "未登录", "尚未注册", "无", "deviceId=device1", "URL_user_group_init", "新设备未登录启动新版本。", "根据 deviceId hash 稳定返回 A/B/C 中一个临时设备组。", "P0", "待测", "", ""],
  ["TC-015", "新用户绑定", "新用户", "新版本", "注册后登录", "register_time >= timeA", "空", "B", "URL_user_group_msg", "init 得到 B 后注册/登录。", "绑定并返回 B；用户表写入 B。", "P0", "待测", "", ""],
  ["TC-016", "新用户绑定", "新用户", "新版本", "注册后登录", "register_time >= timeA", "空", "C", "URL_user_group_msg", "init 得到 C 后注册/登录。", "绑定并返回 C；用户表写入 C。", "P0", "待测", "", ""],
  ["TC-017", "新用户绑定", "新用户", "新版本", "注册后登录", "register_time >= timeA", "空", "A", "URL_user_group_msg", "init 得到 A 后注册/登录。", "绑定并返回 A；用户表写入 A。", "P0", "待测", "", ""],
  ["TC-018", "新用户已分组", "新用户", "新版本", "已登录", "register_time >= timeA", "B", "任意", "config/get 或 URL_user_group_msg", "已有 user_group=B 的新用户启动新版本。", "返回 B；不重新 hash。", "P0", "待测", "", ""],
  ["TC-019", "换设备一致性", "新用户", "新版本", "已登录", "register_time >= timeA", "C", "新设备 hash=A/B", "URL_user_group_msg", "已有 user_group=C 的新用户换设备登录。", "返回用户表已有 C；不被新设备 hash 覆盖。", "P0", "待测", "", ""],
  ["TC-020", "初始化失败兜底", "新用户", "新版本", "注册后登录", "register_time >= timeA", "空", "init 未成功", "URL_user_group_msg", "跳过或模拟 URL_user_group_init 失败后注册/登录。", "后台有兜底分组策略，返回 A/B/C 中一个有效组并写入用户表；不能返回空。", "P0", "待测", "", ""],
  ["TC-021", "deviceId 稳定性", "新用户", "新版本", "未登录", "尚未注册", "无", "同一 deviceId", "URL_user_group_init", "同一 deviceId 多次调用 init。", "每次返回相同组。", "P1", "待测", "", ""],
  ["TC-022", "多设备一致性", "新用户", "新版本", "多设备登录", "register_time >= timeA", "B", "新设备 hash=C", "URL_user_group_msg", "账号已绑定 B 后在新设备登录。", "最终返回账号已有 B。", "P0", "待测", "", ""],
  ["TC-023", "升级路径", "老用户", "老版本 -> 新版本", "已登录", "register_time < timeA", "A", "无", "config/get", "老用户在老版本已写 A 后升级到新版本。", "升级后继续返回 A。", "P0", "待测", "", ""],
  ["TC-024", "升级路径", "老用户", "老版本 -> 新版本", "已登录", "register_time < timeA", "空", "无", "config/get", "老版本未写入 user_group，升级后已登录启动新版本。", "新版本通过 config/get 返回 A 并写入 A。", "P0", "待测", "", ""],
  ["TC-025", "升级路径", "老用户", "老版本 -> 新版本", "未登录后登录", "register_time < timeA", "空", "B/C", "URL_user_group_msg", "升级后先未登录 init 得到 B/C，再登录老账号。", "最终返回 A；用户表写 A。", "P0", "待测", "", ""],
  ["TC-026", "升级路径", "新用户", "新版本", "未登录后注册", "register_time >= timeA", "空", "B", "URL_user_group_init + URL_user_group_msg", "新版本未登录体验 init 得到 B，随后注册。", "注册后绑定 B。", "P0", "待测", "", ""],
  ["TC-027", "升级路径", "新用户", "老版本 -> 新版本", "注册后升级", "register_time >= timeA", "A 或空", "无", "config/get / URL_user_group_msg", "用户在 timeA 后用老版本注册，后续升级新版本。", "需确认策略：若老版本已写 A，建议保持 A；若为空，需确认是否参与 ABC。", "P0", "待测", "", "关键待确认规则。"],
  ["TC-028", "时间边界", "老用户", "任意版本", "已登录", "register_time = timeA - 1 秒", "空", "任意", "config/get 或 URL_user_group_msg", "构造注册时间早于 timeA 1 秒的用户。", "判定为老用户，返回 A。", "P0", "待测", "", ""],
  ["TC-029", "时间边界", "边界用户", "新版本", "注册后登录", "register_time = timeA", "空", "A/B/C", "URL_user_group_msg", "构造注册时间等于 timeA 的用户。", "按约定处理；建议 register_time >= timeA 算新用户，参与 ABC。", "P0", "待测", "", "必须由后台明确边界。"],
  ["TC-030", "时间边界", "新用户", "新版本", "注册后登录", "register_time = timeA + 1 秒", "空", "A/B/C", "URL_user_group_msg", "构造注册时间晚于 timeA 1 秒的用户。", "判定为新用户，绑定并返回设备分组。", "P0", "待测", "", ""],
  ["TC-031", "时间来源", "新/老用户", "新版本", "注册/登录", "客户端时间错误", "空", "任意", "URL_user_group_msg", "修改客户端时间后注册或登录。", "分组判断以后端注册时间为准，不受客户端时间影响。", "P1", "待测", "", ""],
  ["TC-032", "时区一致性", "新/老用户", "新版本", "注册/登录", "timeA 附近不同时区", "空", "任意", "URL_user_group_msg", "构造接近 timeA 的不同时区注册数据。", "后台统一使用同一时区或 UTC 判断，结果稳定。", "P1", "待测", "", ""],
  ["TC-033", "接口兼容", "任意", "老版本", "任意", "任意", "任意", "无", "config/get", "抓包验证老版本启动流程。", "只调用 config/get；不调用 URL_user_group_init/msg。", "P0", "待测", "", ""],
  ["TC-034", "接口调用", "未知用户", "新版本", "未登录", "尚未注册", "无", "无", "URL_user_group_init", "抓包验证新版本未登录启动流程。", "可调用 URL_user_group_init 并返回临时设备组。", "P1", "待测", "", ""],
  ["TC-035", "接口调用", "用户", "新版本", "登录成功", "任意", "任意", "任意", "URL_user_group_msg", "抓包验证登录成功后流程。", "调用 URL_user_group_msg 获取最终用户组。", "P0", "待测", "", ""],
  ["TC-036", "接口一致性", "用户", "新版本", "已登录", "任意", "任意", "任意", "config/get + URL_user_group_msg", "同一用户启动新版本并触发两个接口。", "两个接口返回的最终分组口径不能冲突。", "P0", "待测", "", ""],
  ["TC-037", "冲突检测", "用户", "新版本", "已登录", "任意", "任意", "任意", "config/get + URL_user_group_msg", "构造或观察 config/get 返回 A、msg 返回 B/C 的情况。", "判定为严重问题；同一用户最终分组必须一致。", "P0", "待测", "", ""],
  ["TC-038", "网络异常", "新用户", "新版本", "未登录", "尚未注册", "无", "无", "URL_user_group_init", "模拟 URL_user_group_init 网络失败。", "客户端/后台有兜底或重试；不能导致后续最终分组为空。", "P1", "待测", "", ""],
  ["TC-039", "网络异常", "新/老用户", "新版本", "登录后", "任意", "任意", "任意", "URL_user_group_msg", "模拟 URL_user_group_msg 网络失败。", "客户端应有重试或默认体验策略；不能错误进入 B/C。", "P0", "待测", "", ""],
  ["TC-040", "幂等性", "新/老用户", "新版本", "已登录", "任意", "已有值", "任意", "URL_user_group_msg", "同一用户重复调用 URL_user_group_msg。", "每次返回一致；不重复改组。", "P0", "待测", "", ""],
  ["TC-041", "数据异常", "老用户", "新版本", "已登录", "register_time < timeA", "空", "任意", "config/get 或 URL_user_group_msg", "老用户 user_group 为空。", "返回 A，写入 A。", "P0", "待测", "", ""],
  ["TC-042", "数据异常", "老用户", "新版本", "已登录", "register_time < timeA", "B/C", "任意", "config/get 或 URL_user_group_msg", "老用户 user_group 异常为 B/C。", "建议修正为 A；最终体验必须为 A。", "P0", "待测", "", ""],
  ["TC-043", "数据异常", "新用户", "新版本", "注册后登录", "register_time >= timeA", "空", "设备分组存在", "URL_user_group_msg", "新用户 user_group 为空但设备分组存在。", "绑定设备分组并返回。", "P0", "待测", "", ""],
  ["TC-044", "数据异常", "新用户", "新版本", "注册后登录", "register_time >= timeA", "空", "设备分组不存在", "URL_user_group_msg", "新用户 user_group 为空且设备分组不存在。", "后台兜底生成 A/B/C 并写入；不能返回空。", "P0", "待测", "", ""],
  ["TC-045", "数据异常", "新用户", "新版本", "已登录", "register_time >= timeA", "已有值", "device hash 不同", "URL_user_group_msg", "用户表已有组，但当前设备 hash 得到不同组。", "返回用户表已有值，不被设备 hash 覆盖。", "P0", "待测", "", ""],
  ["TC-046", "共享设备", "多个新用户", "新版本", "同设备登录", "register_time >= timeA", "空", "同一 deviceId", "URL_user_group_msg", "同一设备注册或登录多个新账号。", "需确认策略；通常多个新账号继承同一设备分组，或按账号独立绑定。结果必须稳定可解释。", "P1", "待测", "", "待确认策略。"],
  ["TC-047", "账号生命周期", "重新注册用户", "新版本", "注销后重新注册", "新账号 register_time >= timeA", "空", "任意", "URL_user_group_msg", "用户注销后用新账号重新注册。", "按新账号注册时间重新判断；新账号参与 ABC。", "P1", "待测", "", ""],
  ["TC-048", "重装场景", "已分组用户", "新版本", "重装后登录", "任意", "已有值", "deviceId 变化", "URL_user_group_init + URL_user_group_msg", "删除 App 重装导致 deviceId 变化，再登录已有账号。", "未登录阶段可重新 init；登录后返回用户表已有分组。", "P0", "待测", "", ""],
];

const rules = [
  ["规则项", "建议/验收口径"],
  ["老用户定义", "register_time < timeA。老用户无论老版本、新版本、已登录、未登录后登录，最终都应为 A。"],
  ["新用户定义", "建议 register_time >= timeA。新用户在新版本上参与 ABC 分组。"],
  ["老版本能力", "老版本没有 URL_user_group_init 和 URL_user_group_msg，全部依赖 config/get 归为 A 或兼容默认策略。"],
  ["新版本未登录", "URL_user_group_init 只能生成临时设备分组；登录后必须以用户注册时间和 user_group 为准。"],
  ["最终分组来源", "user_group 已有值时优先返回已有值；为空时按老用户 A、新用户设备分组绑定的规则初始化。"],
  ["一致性", "config/get 和 URL_user_group_msg 对同一用户的最终分组不能冲突。"],
  ["时间边界", "必须明确 register_time = timeA 的归属；本表建议归为新用户。"],
  ["待确认 1", "timeA 后使用老版本注册的新用户，是否因为老版本不支持 ABC 而统一 A。"],
  ["待确认 2", "老用户脏数据 user_group=B/C 时，后台是否直接覆盖为 A。"],
  ["待确认 3", "同一 deviceId 下多个新账号，是继承同一设备分组还是按账号独立策略。"],
];

const workbook = Workbook.create();

function styleHeader(range) {
  range.format.fill.color = "#1F4E78";
  range.format.font.color = "#FFFFFF";
  range.format.font.bold = true;
  range.format.horizontalAlignment = "center";
  range.format.verticalAlignment = "center";
  range.format.wrapText = true;
}

function styleTitle(range) {
  range.format.fill.color = "#0F172A";
  range.format.font.color = "#FFFFFF";
  range.format.font.bold = true;
  range.format.font.size = 16;
  range.format.verticalAlignment = "center";
}

function applyCommonSheetStyle(sheet, usedRangeAddress) {
  sheet.showGridLines = false;
  const used = sheet.getRange(usedRangeAddress);
  used.format.font.name = "Aptos";
  used.format.font.size = 10;
  used.format.verticalAlignment = "top";
  used.format.wrapText = true;
}

const overview = workbook.worksheets.add("总览");
overview.getRange("A1:H1").merge();
overview.getRange("A1").values = [["ABC Test 分组验收总览"]];
styleTitle(overview.getRange("A1:H1"));
overview.getRange("A3:B10").values = [
  ["统计项", "数量"],
  ["总用例数", cases.length],
  ["P0 用例数", null],
  ["P1 用例数", null],
  ["待测", null],
  ["通过", null],
  ["未通过", null],
  ["阻塞", null],
];
overview.getRange("B5:B10").formulas = [
  ['=COUNTIF(\'详细用例\'!L2:L200,"P0")'],
  ['=COUNTIF(\'详细用例\'!L2:L200,"P1")'],
  ['=COUNTIF(\'详细用例\'!M2:M200,"待测")'],
  ['=COUNTIF(\'详细用例\'!M2:M200,"通过")'],
  ['=COUNTIF(\'详细用例\'!M2:M200,"未通过")'],
  ['=COUNTIF(\'详细用例\'!M2:M200,"阻塞")'],
];
overview.getRange("D3:H9").values = [
  ["测试目标", "确保老用户全部归 A，新用户在 timeA 后按新版本 ABC 策略分组。", "", "", ""],
  ["核心原则", "老用户最终 A；新用户新版本可 ABC；用户表 user_group 已有值时优先稳定返回。", "", "", ""],
  ["老版本限制", "老版本没有 URL_user_group_init/msg，只能靠 config/get。", "", "", ""],
  ["推荐边界", "register_time < timeA 为老用户；register_time >= timeA 为新用户。", "", "", ""],
  ["验收方式", "在「详细用例」逐条填写验收状态、实测结果和备注。", "", "", ""],
  ["重要待确认", "timeA 后用老版本注册的新用户是否统一 A；老用户 B/C 脏数据是否覆盖；同设备多账号策略。", "", "", ""],
  ["文件用途", "供测试、产品、后台按同一口径逐条验收。", "", "", ""],
];
overview.getRange("D3:H9").merge(true);
styleHeader(overview.getRange("A3:B3"));
overview.getRange("A3:B10").format.borders = { preset: "all", style: "thin", color: "#CBD5E1" };
overview.getRange("D3:H9").format.borders = { preset: "all", style: "thin", color: "#CBD5E1" };
overview.getRange("A1:H1").format.rowHeight = 30;
overview.getRange("A:A").format.columnWidth = 18;
overview.getRange("B:B").format.columnWidth = 12;
overview.getRange("D:H").format.columnWidth = 24;
applyCommonSheetStyle(overview, "A1:H10");

const detail = workbook.worksheets.add("详细用例");
const headers = ["用例ID", "模块/场景", "用户类型", "App版本", "登录状态", "注册时间/边界", "user_group前置", "设备分组前置", "触发接口", "操作步骤", "预期结果", "优先级", "验收状态", "实测结果", "备注"];
detail.getRangeByIndexes(0, 0, 1, headers.length).values = [headers];
detail.getRangeByIndexes(1, 0, cases.length, headers.length).values = cases;
styleHeader(detail.getRange("A1:O1"));
detail.freezePanes.freezeRows(1);
detail.getRange("A1:O49").format.borders = {
  insideHorizontal: { style: "thin", color: "#E2E8F0" },
  insideVertical: { style: "thin", color: "#E2E8F0" },
  top: { style: "thin", color: "#CBD5E1" },
  bottom: { style: "thin", color: "#CBD5E1" },
  left: { style: "thin", color: "#CBD5E1" },
  right: { style: "thin", color: "#CBD5E1" },
};
detail.getRange("A:A").format.columnWidth = 12;
detail.getRange("B:B").format.columnWidth = 16;
detail.getRange("C:C").format.columnWidth = 14;
detail.getRange("D:D").format.columnWidth = 16;
detail.getRange("E:E").format.columnWidth = 16;
detail.getRange("F:F").format.columnWidth = 22;
detail.getRange("G:H").format.columnWidth = 16;
detail.getRange("I:I").format.columnWidth = 24;
detail.getRange("J:K").format.columnWidth = 42;
detail.getRange("L:M").format.columnWidth = 12;
detail.getRange("N:O").format.columnWidth = 28;
detail.getRange("A1:O49").format.rowHeight = 48;
detail.getRange("A1:O1").format.rowHeight = 32;
detail.getRange("A1:O49").format.verticalAlignment = "top";
detail.getRange("A1:O49").format.wrapText = true;
detail.getRange("L2:M49").format.horizontalAlignment = "center";
detail.getRange("M2:M200").dataValidation = { rule: { type: "list", values: statusValues } };
detail.getRange("L2:L49").dataValidation = { rule: { type: "list", values: ["P0", "P1", "P2"] } };
applyCommonSheetStyle(detail, "A1:O49");

const rulesSheet = workbook.worksheets.add("规则与边界");
rulesSheet.getRangeByIndexes(0, 0, rules.length, 2).values = rules;
styleHeader(rulesSheet.getRange("A1:B1"));
rulesSheet.freezePanes.freezeRows(1);
rulesSheet.getRange(`A1:B${rules.length}`).format.borders = { preset: "all", style: "thin", color: "#CBD5E1" };
rulesSheet.getRange("A:A").format.columnWidth = 22;
rulesSheet.getRange("B:B").format.columnWidth = 90;
rulesSheet.getRange(`A1:B${rules.length}`).format.rowHeight = 42;
applyCommonSheetStyle(rulesSheet, `A1:B${rules.length}`);

const preview1 = await workbook.render({ sheetName: "详细用例", range: "A1:O12", scale: 1, format: "png" });
await fs.writeFile(`${outputDir}/preview_detail.png`, new Uint8Array(await preview1.arrayBuffer()));

const inspect = await workbook.inspect({
  kind: "table",
  sheetId: "详细用例",
  range: "A1:O8",
  include: "values,formulas",
  tableMaxRows: 8,
  tableMaxCols: 15,
  maxChars: 6000,
});
console.log(inspect.ndjson);

const errors = await workbook.inspect({
  kind: "match",
  searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A",
  options: { useRegex: true, maxResults: 300 },
  summary: "final formula error scan",
});
console.log(errors.ndjson);

await fs.mkdir(outputDir, { recursive: true });
const output = await SpreadsheetFile.exportXlsx(workbook);
await output.save(outputPath);
console.log(outputPath);
