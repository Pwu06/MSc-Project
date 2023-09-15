# MSc-Project
Project Title: Transponder anti-collision in a software RFID receiver

Initialisation: 
1. Build the setup:                 Connect the oscilloscope and Arduino board to the PC.
2. Connection:                      Connect the cables based on the setup diagram.
3. Check the oscilloscope setup:    Adjust the impedance for the channel and close the auto trigger.
4. Upload the code to the R3 board: Run the Arduino code "modify_test_version.ino" in Arduino IDE, the delay function "delay_x.h" should be placed in the same folder.
5. Check the code file path:        All the Matlab functions should be placed in the same folder with the main code.

Test:
1. Check the serial port:                  The serial port for the Arduino shall be "COM3" normally. It might be different for Windows and MAC.
2. Find the address of the oscilloscope:   Copy the address to the function "InitialiseScope.m" in the folder "oscilloscope".
3. Run the command code:                   Run ".m" in MATLAB.
4. Check the waveform:                     If the waveform is not observed on the oscilloscope, check the device connections and whether the function generator is outputting.
5. Run the main code:                      Run "Tag_decode.m" in MATLAB without placing the card on the transmitter antenna.   
6. Test one card:                          Put one card on the transmitter antenna and observe the waveform.

Decode Card:
1. Put the cards on the transmitter antenna.
2. Run the main code.
3. 
