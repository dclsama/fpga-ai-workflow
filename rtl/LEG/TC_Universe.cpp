#include <verilated.h>
#include <iostream>
#include <chrono>
#include <thread>
#include <fstream>
#include "verilated_vcd_c.h"
#include "string.h"

#include "VLEG.h"

VLEG * top; // Instantiation of model
uint64_t main_time = 0; // Current simulation time
// This is a 64-bit integer to reduce wrap over issues and
// allow modulus. This is in units of the timeprecision
// used in Verilog (or from --timescale-override)
double sc_time_stamp() { // Called by $time in Verilog
  return main_time; // converts to double, to match
  // what SystemC does
}
int main(int argc, char ** argv) {
  Verilated::commandArgs(argc, argv); // Remember args
  Verilated::traceEverOn(true);

  unsigned char buffer[256*256] = {0};
  int max_tick_count = 1000;
  int delta_ms = 0;
  
  const char* argument = Verilated::commandArgsPlusMatch("INPUT_FILE=");
  if (argument && 0==strncmp(argument, "+INPUT_FILE=", 12)) {
    const char* file_name = argument + 12;
    std::ifstream input_file(file_name);
    int index = 0;
    while(input_file) {
      buffer[index] = input_file.get();
      index++;
    }
    std::cout << "Read " << index << " bytes from file " << file_name << std::endl;
    std::cout << buffer << std::endl;
  }
  argument = Verilated::commandArgsPlusMatch("MAX_TICK=");
  if (argument && 0==strncmp(argument, "+MAX_TICK=", 10)) {
    max_tick_count = atoi(argument + 10);
  }
  argument = Verilated::commandArgsPlusMatch("DELTA=");
  if (argument && 0==strncmp(argument, "+DELTA=", 7)) {
    delta_ms = atoi(argument + 7);
  }
  top = new VLEG; // Create model


  
  top -> rst = 1; // Set some inputs
  
  unsigned short buffer_pointer = 0;
  top -> arch_input_value = buffer[0];

  std::chrono::time_point<std::chrono::system_clock> t = std::chrono::system_clock::now();
  while (!Verilated::gotFinish()) {
    if ((main_time % 2) == 1) {
      top -> clk = 1; // Toggle clock
      if (!top->rst) {
        if (top -> arch_output_enable) {
          std::cout << (char)(top->arch_output_value);
        }
        if (top -> arch_input_enable && main_time > 4) {
          buffer_pointer += 1;
        }
        top -> arch_input_value = buffer[buffer_pointer];
      }
    }
    if ((main_time % 2) == 0) {
      top -> clk = 0;
    }
    if (main_time > 2) {
      top -> rst = 0; // Deassert reset
    }
    
    if(max_tick_count > 0 && main_time > max_tick_count * 2) break;
    
    top -> eval(); // Evaluate model

   main_time++; // Time passes...
    t+=std::chrono::milliseconds(delta_ms);
    std::this_thread::sleep_until(t);
  }

  top -> final(); // Done simulating
  delete top;
}