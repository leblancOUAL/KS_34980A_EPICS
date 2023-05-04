# List of SCPI commands used in this module

## Identification

* IDN: The command `*IDN?` will identify the device, and will return something like 
`"Agilent Technologies,34951A,MY56480681,2.17"`.

* Ctype: The command `SYSTem:CTYPe? N` where `N` is the slot number will return the 
model number and firmware version of the module in the specified slot (1-8).  The 
output looks something like `"Agilent Technologies,34951A,MY56480681,2.17"`.

* Cdescription: The command `SYSTem:CDEScription? N` where `N` is the slot number 
will return the description of the module in the specified slot (1-8).  The output
looks something like `"4-Channel Isolated D/A Converter with Waveform Memory"`.

## Measurement

* measure:resistance?: The `measure:resistance? (@NNNN)` command will measure the 
resistance on the channel specified by `NNNN`.  The first digit of the channel 
number specifies the slot number of the card, while the last 3 numbers specify which
input on that particular card to use.

  * The measure resitance command can be specified as 
  `MEASure:RESistance? [{<range>|AUTO|MIN|MAX|DEF} [,{<resolution>|MIN|MAX|DEF}] , ] [(@<ch_list>)]`
  where the range can be [100, 1000, 10000, 100000, 1000000, 10000000, 100000000].
  The resolution can be specified in ohms.  The default is 0.000003 x Range, which gives a 20-bit,
  or 5 1/2 digit readout, and will be used if the resolution parameter is omitted.  More resolution 
  makes things slower, less makes things faster.

* measure:voltage:dc?: The `measure:voltage? (@NNNN)` command will measure the 
  resistance on the channel specified by `NNNN`.  The first digit of the channel 
  number specifies the slot number of the card, while the last 3 numbers specify which
  input on that particular card to use.  

    * The measure voltage command can be specified as 
  `MEASure[:VOLTage][:DC]? [{<range>|AUTO|MIN|MAX|DEF} [,{<resolution>|MIN|MAX|DEF}] , ] [(@<ch_list>)]`
  where the "DEF" for range can be [0.1, 1, 10, 100, 300].  The resolution can also be specified 
  in volts.  The default is 0.000003 x Range, which gives a 20-bit,   or 5 1/2 digit readout, and 
  will be used if the resolution parameter is omitted.  More resolution makes things slower, less
  makes things faster.

