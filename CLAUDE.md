# FPGA AI自动化开发工作流 — CLAUDE.md

这是AI驱动的FPGA/Verilog开发工作流项目。你的角色是FPGA开发助手，协助用户完成从RTL编写到仿真验证的完整流程。

## 目录结构

```
rtl/          # Verilog RTL源文件 (.v)
tb/           # Testbench文件 (.sv)
sim/<MODULE>/ # 仿真产物 (日志、波形)
scripts/      # 自动化脚本
  sim.sh             # 主编排脚本
  run_sim.tcl        # 批量仿真Tcl
  wave_view.tcl      # 波形GUI Tcl
  export_signals.tcl # VCD导出Tcl
  parse_sim_log.py   # 日志解析
```

## Verilog编码规范

### 命名约定
- 时钟: `clk`
- 复位: `rst_n` (低电平有效)
- 输入端口: `i_<name>` (如 `i_data`, `i_enable`)
- 输出端口: `o_<name>` (如 `o_data`, `o_valid`)
- 内部连线: `w_<name>` (如 `w_ready`, `w_result`)
- 内部寄存器: 直接用 `reg` 命名, 如 `counter`, `state`
- 参数: 大写蛇形 `DATA_WIDTH`, `MAX_COUNT`

### 端口顺序
时钟 → 复位 → 控制输入 → 数据输入 → 数据输出 → 状态输出

### 文件头
每个RTL文件必须包含模块名、功能描述、参数说明和端口列表的注释头。

## Testbench编写规范

每个testbench **必须** 包含以下内容：

### 1. 基本结构
```systemverilog
`timescale 1ns / 1ps
module <module>_tb;
    // 信号声明 → DUT实例化 → 时钟生成 → 复位生成 → 测试用例 → 汇总报告
endmodule
```

### 2. 必需组件
- **时钟生成**: `always #5 clk = ~clk;` (100MHz, 可根据需要调整)
- **复位序列**: 拉低 ≥10个时钟周期后释放
- **波形导出**:
  ```systemverilog
  initial begin
      $dumpfile("sim/<module>/<module>_tb.vcd");
      $dumpvars(0, <module>_tb);
  end
  ```
- **自检断言**: 每个测试用例必须包含PASS/FAIL标记
  ```systemverilog
  if (expected !== actual) begin
      $error("FAIL at time %t: expected %h, got %h", $time, expected, actual);
  end else begin
      $display("PASS: <test description>");
  end
  ```
- **汇总报告**: 测试结束后打印通过/失败数量
  ```systemverilog
  $display("=== ALL TESTS PASSED ===");  // 或
  $display("=== %0d TEST(S) FAILED ===", fail_count);
  ```

### 3. 测试组织
- 使用 `task` 封装可复用的测试操作
- 每个测试用例用 `$display("[TEST N] description")` 标记
- 使用 `integer` 计数器跟踪通过/失败数量

## 仿真工作流

### 基本命令
```bash
./scripts/sim.sh sim <module>     # 完整仿真: xvlog → xelab → xsim
./scripts/sim.sh wave <module>    # 打开波形GUI
./scripts/sim.sh clean <module>   # 清理仿真产物
./scripts/sim.sh export <module>  # 导出VCD文本波形
./scripts/sim.sh parse <module>   # 解析日志提取错误
```

### AI调试循环

当用户要求测试一个设计时，按以下步骤操作：

1. **确认RTL和TB文件存在** - 检查 `rtl/<module>.v` 和 `tb/<module>_tb.sv`
2. **运行仿真** - `bash scripts/sim.sh sim <module>`
3. **分析日志** - 读取 `sim/<module>/<module>_sim.log`
4. **如果编译失败** (xvlog/xelab错误)：
   - 读取对应的 `.log` 文件
   - 根据错误信息修复RTL或TB的语法/连接问题
   - 返回步骤2
5. **如果仿真失败** ($error/$fatal)：
   - 运行 `bash scripts/sim.sh parse <module>` 获取结构化错误报告
   - 定位根因：RTL逻辑错误还是TB激励错误？
   - 修复后返回步骤2
6. **如果波形异常但无显式错误**：
   - 运行 `bash scripts/sim.sh export <module>` 导出VCD
   - 读取 `sim/<module>/<module>_tb.vcd` 检查信号时序
   - 也可运行 `bash scripts/sim.sh wave <module>` 让用户手动查看波形GUI

**最多迭代5轮**。5轮后仍有问题，向用户说明现状并请求指导。

### 仿真日志位置
- 编译日志: `sim/<module>/<module>_xvlog.log`
- 细化日志: `sim/<module>/<module>_elab.log`
- 仿真日志: `sim/<module>/<module>_sim.log`
- 波形数据: `sim/<module>/<module>_tb.wdb`

## 文件创建规则

- 新的RTL模块: `rtl/<module>.v` (参考 `rtl/_template.v`)
- 新的Testbench: `tb/<module>_tb.sv` (参考 `tb/_template_tb.sv`)
- 命名必须匹配: 模块 `counter.v` 对应TB `counter_tb.sv`

## Vivado工具链

- Vivado 2025.1 安装在 `D:\Xilinx\2025.1\Vivado`
- `sim.sh` 会自动 source `settings64.sh`
- xvlog: 分析Verilog源码
- xelab: 细化设计，`--debug wave` 启用波形
- xsim: 运行仿真，`--tclbatch` 批量模式，`--gui` 图形模式

## 常见问题速查

| 问题 | 原因 | 解决 |
|------|------|------|
| `xvlog` 找不到 | settings64.sh未source | sim.sh已自动处理 |
| `xelab` 报无法找到模块 | 模块名不匹配或文件未找到 | 检查文件名和模块名一致 |
| 波形无信号 | 缺 $dumpfile/$dumpvars 或 --debug wave | 检查TB和xelab参数 |
| `$finish` 后无PASS输出 | 测试中断或未到汇总代码 | 检查是否提前触发$finish |
| VCD文件为空 | WDB未正确导出 | 使用 `sim.sh export` 重新导出 |
