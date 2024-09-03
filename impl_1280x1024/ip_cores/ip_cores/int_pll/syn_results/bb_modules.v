`timescale 100 ps/100 ps
module EHXPLLM (
  CLKI,
  CLKFB,
  PHASESEL1,
  PHASESEL0,
  PHASEDIR,
  PHASESTEP,
  PHASELOADREG,
  PLLWAKESYNC,
  RST,
  ENCLKOP,
  ENCLKOS,
  ENCLKOS2,
  ENCLKOS3,
  USRSTDBY,
  CLKOP,
  CLKOS,
  CLKOS2,
  CLKOS3,
  LOCK,
  INTLOCK,
  REFCLK,
  CLKINTFB
)
;
input CLKI ;
input CLKFB ;
input PHASESEL1 ;
input PHASESEL0 ;
input PHASEDIR ;
input PHASESTEP ;
input PHASELOADREG ;
input PLLWAKESYNC ;
input RST ;
input ENCLKOP ;
input ENCLKOS ;
input ENCLKOS2 ;
input ENCLKOS3 ;
input USRSTDBY ;
output CLKOP ;
output CLKOS ;
output CLKOS2 ;
output CLKOS3 ;
output LOCK ;
output INTLOCK ;
output REFCLK ;
output CLKINTFB ;
endmodule /* EHXPLLM */

