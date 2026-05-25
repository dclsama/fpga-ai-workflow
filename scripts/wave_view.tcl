# =============================================================================
# wave_view.tcl - Open Vivado waveform GUI with all top-level signals
# Usage: xsim --gui --tclbatch wave_view.tcl <snapshot>.wdb
# =============================================================================

# Open the waveform database
open_wave_database SIM_DIR/SNAPSHOT.wdb

# Add all signals from root to the waveform window
add_wave /*

# Optional: organize signals into groups
# add_wave -group "Inputs"  /SNAPSHOT/clk /SNAPSHOT/rst_n
# add_wave -group "Outputs" /SNAPSHOT/o_*
