# VHDL Parking System Project

## Project Overview
This VHDL project simulates a parking system. It includes VHDL code for managing car entries and exits in a parking lot, tracking parking times, and calculating fees. The project is structured into several VHDL files representing different components of the parking system.

## Components
The project consists of the following main components:
1. **Computer**: This is the central unit that coordinates the operations of the parking system.
2. **InterfaceMasuk**: This interface handles the entry of cars into the parking lot.
3. **InterfaceKeluar**: This interface manages the exit of cars from the parking lot.
4. **Parking Memory**: This component is used for storing and retrieving parking data.

Each component is encapsulated in its VHDL file with appropriate entity and architecture declarations.

## System Operation
- **Entry Process**: When a car enters, the `InterfaceMasuk` component is triggered, which records the entry time and car details.
- **Exit Process**: When a car exits, the `InterfaceKeluar` component calculates the parking fee based on the duration of stay.


## Limitations & Future Enhancements
- Currently, the system handles a basic entry and exit scenario. Future enhancements could include handling multiple entries/exits simultaneously or incorporating a more complex fee structure.
- Error handling and system robustness can be further improved.
