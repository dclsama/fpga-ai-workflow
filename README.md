# FPGA AI自动化开发工作流

AI驱动的Verilog开发、仿真验证、波形分析和调试排错工作流。

## 环境要求

- **Vivado 2025.1** (或更新版本) — 提供 xvlog / xelab / xsim
- **Python 3** — 用于仿真日志解析
- **Git Bash** (MINGW64) — 运行脚本

## 快速开始

### 1. 编写RTL模块

在 `rtl/` 下创建你的Verilog模块, 可参考模板 `rtl/_template.v`:

```verilog
// rtl/counter.v
module counter (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        i_en,
    output wire [7:0]  o_count
);
    reg [7:0] count;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) count <= 0;
        else if (i_en) count <= count + 1;
    end
    assign o_count = count;
endmodule
```

### 2. 编写Testbench

在 `tb/` 下创建对应的testbench, 命名格式 `模块名_tb.sv`:

```systemverilog
// tb/counter_tb.sv
`timescale 1ns/1ps
module counter_tb;
    // ... DUT实例化, 时钟, 测试用例 ...
endmodule
```

### 3. 运行仿真

```bash
# 完整仿真流程
./scripts/sim.sh sim counter

# 查看波形GUI
./scripts/sim.sh wave counter

# 导出VCD供AI分析
./scripts/sim.sh export counter

# 解析仿真日志
./scripts/sim.sh parse counter

# 清理仿真文件
./scripts/sim.sh clean counter
```

## 工作流

```
需求描述 → AI编写RTL → AI编写TB → sim.sh sim → 检查日志/波形 → 通过? → 完成
                                                    ↑              ↓
                                                    └── AI调试修复 ←─ 失败
```

## 目录结构

```
FPGA人工智能开发工作流/
├── rtl/              # Verilog RTL源文件
│   └── _template.v   # 模块模板
├── tb/               # SystemVerilog Testbench
│   └── _template_tb.sv
├── sim/<MODULE>/     # 仿真产物 (自动生成)
├── scripts/          # 自动化脚本
│   ├── sim.sh        # 主编排脚本
│   ├── run_sim.tcl   # 批量仿真
│   ├── wave_view.tcl # 波形查看
│   ├── export_signals.tcl
│   └── parse_sim_log.py
└── CLAUDE.md         # AI助手指引
```

## CLAUDE.md

使用Claude Code时, 项目根目录的 `CLAUDE.md` 会自动加载, 为AI提供Verilog编码规范、testbench编写要求和调试流程的完整指引。
