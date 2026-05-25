# =============================================================================
# export_signals.tcl - Export WDB waveform to VCD text format for AI analysis
# Usage: xsim --tclbatch export_signals.tcl
# The snapshot name is passed via Tcl variable set by the caller.
# =============================================================================

# Open the waveform database
open_wave_database SIM_DIR/SNAPSHOT.wdb

# Open VCD file for writing
open_vcd SIM_DIR/SNAPSHOT.vcd

# Log all signals recursively
log_vcd [get_objects -r /*]

# Re-run to capture all waveform data into VCD
run all

close_vcd
quit
