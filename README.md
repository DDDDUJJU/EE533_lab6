# EE533_lab6

To compile project:
```
cd synth
make
```
## Usage
Interface usage:
```
./pipelinereg <command>
```
Firstly run:
```
./pipelinereg initialize
```
This command will load 5 instructions (LD, LD, NOP, NOP, SW) to instruction memory, and decimal value 4 and 100 to address 0x0 and 0x4 of data memory respectively.

Ideally, mem(0x0) will be loaded into register 2 and 3, then, value of reg 2 will be stored into mem(reg3).

Finally mem(0x4) should store decimal value 4.

Initially the pipeline is stalled (stage registers disabled), so that we can preload memories. To enable pipeline, run:
```
./pipeline start
```
And to stop it run:
```
./pipeline stop
```
To validate pipeline execution, read data memory:
```
./pipeline readmem 4
```
Desired ouput should be like:
```
Setting data mem pointer to 0x40000004  
Read data mem at 0x40000004 :0x0000000000000004
```

## Details
To realize write/read enables exclusively for the interface, when setting w/r address, bits 31 and 30 will be reserved for repersenting w/r enable.  
For example, writing instruction memory at 0x4, 0x80000004 will be send to the pipeline. Bit 31 represents write enable. (We didn't implement reading interface for inst mem)  
As for data memory. writing will be 0x80000xxx, and reading will be 0x40000xxx.

Since inst/data mem inputs are muxed, selecting either pipeline signals or interface signals, it is suggested that all manual operations are performed when the pipeline is not running.

That means, this interface cannot be used as logic analyzer.