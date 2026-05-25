#!/usr/bin/env bash
# =============================================================================
# sim.sh - FPGA Simulation Workflow Driver (Vivado XSim)
# =============================================================================
# Usage:
#   ./scripts/sim.sh sim    <module>    Run full simulation (xvlog->xelab->xsim)
#   ./scripts/sim.sh wave   <module>    Open waveform in Vivado GUI
#   ./scripts/sim.sh clean  <module>    Remove simulation artifacts
#   ./scripts/sim.sh export <module>    Export waveform to VCD text
#   ./scripts/sim.sh parse  <module>    Parse simulation log for errors
# =============================================================================

set -euo pipefail

# ---- Configuration -----------------------------------------------------------
VIVADO_DIR="/d/Xilinx/2025.1/Vivado"
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"
RTL_DIR="$PROJECT_ROOT/rtl"
TB_DIR="$PROJECT_ROOT/tb"

# ---- Source Vivado environment -----------------------------------------------
if [ -f "$VIVADO_DIR/settings64.sh" ]; then
    source "$VIVADO_DIR/settings64.sh" 2>/dev/null
else
    echo "ERROR: Vivado settings64.sh not found at $VIVADO_DIR/settings64.sh"
    echo "Please update VIVADO_DIR in this script to match your Vivado installation."
    exit 1
fi

# ---- Help --------------------------------------------------------------------
usage() {
    echo "Usage: $0 <command> <module>"
    echo ""
    echo "Commands:"
    echo "  sim     <module>   Run full simulation (xvlog -> xelab -> xsim)"
    echo "  wave    <module>   Open waveform in Vivado GUI"
    echo "  clean   <module>   Remove simulation artifacts for the module"
    echo "  export  <module>   Export waveform database to VCD text"
    echo "  parse   <module>   Parse simulation log and report errors"
    echo ""
    echo "Examples:"
    echo "  $0 sim    counter"
    echo "  $0 wave   counter"
    echo "  $0 clean  counter"
    exit 0
}

# ---- Argument parsing --------------------------------------------------------
CMD="${1:-}"
MODULE="${2:-}"

if [ -z "$CMD" ] || [ -z "$MODULE" ]; then
    usage
fi

SIM_DIR="$PROJECT_ROOT/sim/$MODULE"
SNAPSHOT="${MODULE}_tb"

# ---- Helper: find RTL files --------------------------------------------------
find_rtl_files() {
    # Exclude template files (starting with _)
    local files
    files=$(find "$RTL_DIR" -maxdepth 1 \( -name "*.v" -o -name "*.sv" \) ! -name "_*" 2>/dev/null | sort)
    if [ -z "$files" ]; then
        echo "WARNING: No RTL files found in $RTL_DIR/"
        echo "  Make sure your Verilog source files are in the rtl/ directory."
    fi
    echo "$files"
}

# ---- Helper: find TB files ---------------------------------------------------
find_tb_files() {
    # Look for the specific testbench matching the module name
    local tb_file="$TB_DIR/${MODULE}_tb.sv"
    if [ -f "$tb_file" ]; then
        echo "$tb_file"
        return
    fi
    tb_file="$TB_DIR/${MODULE}_tb.v"
    if [ -f "$tb_file" ]; then
        echo "$tb_file"
        return
    fi
    echo "ERROR: Testbench not found: $TB_DIR/${MODULE}_tb.sv or ${MODULE}_tb.v"
    echo "  Create a testbench at tb/${MODULE}_tb.sv"
    return 1
}

# ---- Helper: ensure sim directory exists -------------------------------------
ensure_sim_dir() {
    mkdir -p "$SIM_DIR"
}

# ---- Command: clean ----------------------------------------------------------
cmd_clean() {
    if [ -d "$SIM_DIR" ]; then
        echo "Cleaning $SIM_DIR ..."
        rm -rf "$SIM_DIR"
        echo "Done."
    else
        echo "Nothing to clean (sim/$MODULE does not exist)."
    fi
}

# ---- Command: sim ------------------------------------------------------------
cmd_sim() {
    local rtl_files
    local tb_files

    rtl_files=$(find_rtl_files)
    tb_files=$(find_tb_files) || return 1

    # Clean previous artifacts
    cmd_clean
    ensure_sim_dir

    # ---- Step 1: xvlog (analyze Verilog sources) ----------------------------
    echo "=== [1/3] xvlog: Analyzing Verilog sources ==="
    # Build relative paths from the sim dir back to project root
    local xvlog_cmd="xvlog -work work"
    for f in $rtl_files; do
        xvlog_cmd="$xvlog_cmd \"$PROJECT_ROOT/${f#$RTL_DIR/}\""
    done
    xvlog_cmd="$xvlog_cmd --sv \"$PROJECT_ROOT/${tb_files#$TB_DIR/}\""

    # Fix: build paths using full paths so xvlog works from sim dir
    local xvlog_cmd_full="xvlog -work work"
    for f in $rtl_files; do
        xvlog_cmd_full="$xvlog_cmd_full \"$f\""
    done
    xvlog_cmd_full="$xvlog_cmd_full --sv \"$tb_files\""

    echo "  $xvlog_cmd_full"
    local xvlog_log="$SIM_DIR/${MODULE}_xvlog.log"
    # Run xvlog inside sim/MODULE/ to isolate library artifacts
    if (cd "$SIM_DIR" && eval "$xvlog_cmd_full" > "$(basename "$xvlog_log")" 2>&1); then
        echo "  xvlog PASSED"
    else
        echo "  xvlog FAILED - see $xvlog_log"
        echo ""
        echo "--- Last 30 lines of log ---"
        tail -30 "$xvlog_log"
        return 1
    fi

    # ---- Step 2: xelab (elaborate design) -----------------------------------
    echo "=== [2/3] xelab: Elaborating design ==="
    local xelab_cmd="xelab"
    xelab_cmd="$xelab_cmd --debug wave"
    xelab_cmd="$xelab_cmd -L work"
    xelab_cmd="$xelab_cmd --snapshot \"$SNAPSHOT\""
    xelab_cmd="$xelab_cmd \"work.${MODULE}_tb\""

    echo "  $xelab_cmd"
    local elab_log="$SIM_DIR/${MODULE}_elab.log"
    # Run xelab inside sim/MODULE/ so snapshot and artifacts are isolated
    if (cd "$SIM_DIR" && eval "$xelab_cmd" > "$(basename "$elab_log")" 2>&1); then
        echo "  xelab PASSED"
    else
        echo "  xelab FAILED - see $elab_log"
        echo ""
        echo "--- Last 30 lines of log ---"
        tail -30 "$elab_log"
        return 1
    fi

    # ---- Step 3: xsim (run simulation) ---------------------------------------
    echo "=== [3/3] xsim: Running simulation ==="
    # Copy Tcl script into sim dir
    cp "$SCRIPTS_DIR/run_sim.tcl" "$SIM_DIR/run_sim.tcl"

    local xsim_cmd="xsim"
    xsim_cmd="$xsim_cmd \"$SNAPSHOT\""
    xsim_cmd="$xsim_cmd --tclbatch run_sim.tcl"

    echo "  $xsim_cmd"
    local sim_log="$SIM_DIR/${MODULE}_sim.log"
    # Run xsim inside sim/MODULE/ so all artifacts stay there
    if (cd "$SIM_DIR" && eval "$xsim_cmd" > "$(basename "$sim_log")" 2>&1); then
        echo "  xsim PASSED"
    else
        echo "  xsim completed (check log for test failures)"
    fi

    echo ""
    echo "=== Simulation complete ==="
    echo "  Log:   $sim_log"

    # Check for WDB file in sim/MODULE/ directory
    local wdb_file
    wdb_file=$(find "$SIM_DIR" -name "*.wdb" 2>/dev/null | head -1)
    if [ -n "$wdb_file" ]; then
        echo "  Wave:  $wdb_file"
    fi

    echo ""
    echo "--- Simulation output (last 25 lines) ---"
    tail -25 "$sim_log"
}

# ---- Command: wave -----------------------------------------------------------
cmd_wave() {
    local wdb_file

    # Search for WDB in sim directory
    wdb_file=$(find "$SIM_DIR" -name "*.wdb" 2>/dev/null | head -1)

    if [ -z "$wdb_file" ]; then
        echo "ERROR: No waveform database (.wdb) found."
        echo "  Run './scripts/sim.sh sim $MODULE' first to generate waveforms."
        exit 1
    fi

    # Prepare wave view Tcl with correct paths
    local wv_tcl="$SIM_DIR/wave_view.tcl"
    sed -e "s|SIM_DIR|$SIM_DIR|g" -e "s|SNAPSHOT|$SNAPSHOT|g" \
        "$SCRIPTS_DIR/wave_view.tcl" > "$wv_tcl"

    echo "Opening waveform: $wdb_file"
    echo "Use Vivado GUI to inspect signals. Close the window when done."
    xsim --gui --tclbatch "$wv_tcl" --view "$wdb_file"
}

# ---- Command: export ---------------------------------------------------------
cmd_export() {
    local wdb_file
    wdb_file=$(find "$SIM_DIR" -name "*.wdb" 2>/dev/null | head -1)

    if [ -z "$wdb_file" ]; then
        echo "ERROR: No waveform database (.wdb) found."
        echo "  Run './scripts/sim.sh sim $MODULE' first to generate waveforms."
        exit 1
    fi

    # Prepare export Tcl with correct paths
    local exp_tcl="$SIM_DIR/export_signals.tcl"
    sed -e "s|SIM_DIR|.|g" -e "s|SNAPSHOT|$SNAPSHOT|g" \
        "$SCRIPTS_DIR/export_signals.tcl" > "$exp_tcl"

    echo "Exporting waveform to VCD..."
    echo "  WDB: $wdb_file"
    echo "  Tcl: $exp_tcl"

    # Run xsim inside sim/MODULE/ to export VCD
    if (cd "$SIM_DIR" && xsim "$SNAPSHOT" --tclbatch export_signals.tcl > vcd_export.log 2>&1); then
        local vcd_file="$SIM_DIR/${SNAPSHOT}.vcd"
        if [ -f "$vcd_file" ]; then
            echo "  VCD exported: $vcd_file"
        else
            echo "  VCD export may have failed. Check $SIM_DIR/vcd_export.log"
        fi
    else
        echo "  VCD export failed. See $SIM_DIR/vcd_export.log"
        echo ""
        echo "--- Log ---"
        cat "$SIM_DIR/vcd_export.log"
    fi
}

# ---- Command: parse ----------------------------------------------------------
cmd_parse() {
    local sim_log="$SIM_DIR/${MODULE}_sim.log"

    if [ ! -f "$sim_log" ]; then
        echo "ERROR: Simulation log not found: $sim_log"
        echo "  Run './scripts/sim.sh sim $MODULE' first."
        exit 1
    fi

    echo "Parsing simulation log: $sim_log"
    python3 "$SCRIPTS_DIR/parse_sim_log.py" "$sim_log"
}

# ---- Main dispatch -----------------------------------------------------------
case "$CMD" in
    sim)
        cmd_sim
        ;;
    wave)
        cmd_wave
        ;;
    clean)
        cmd_clean
        ;;
    export)
        cmd_export
        ;;
    parse)
        cmd_parse
        ;;
    *)
        echo "ERROR: Unknown command '$CMD'"
        usage
        ;;
esac
