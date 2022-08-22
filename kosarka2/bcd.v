`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:12:14 01/31/2017 
// Design Name: 
// Module Name:    bcd 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module bcd(clk, broj, desetice, jedinice);
   input clk;																// Klok
	input  [7:0] broj;													// Broj koji treba da se konvertuje
   output reg [3:0] desetice;											// BCD desetice
   output reg [3:0] jedinice;											// BCD jedinice
   
   reg [15:0] shift;														// Unutrasnja promenljiva za cuvanje bitova
   reg [3:0] i = 0;														// Broj iteracija u petlji
   
   always @(posedge clk)
   begin
      if(i == 0)															// Ocisti prethodni broj i cuvaj novi u shift registru
		begin
			shift[15:8] = 0;
			shift[7:0] = broj;
      end
      
		if(i<8)																// Iteriraj osam puta
		begin
			if (shift[11:8] >= 5)										// Ako je kolona jedinica >=5..
            shift[11:8] = shift[11:8] + 3;						// ..dodaj 3
            
         if (shift[15:12] >= 5)										// Ako je kolona desetica >=5..
            shift[15:12] = shift[15:12] + 3;						// ..dodaj 3
         
         shift = shift << 1;											// Shiftuj ceo registar levo jednom
			i = i+1;
		end
      else																	// Decimalni broojevi na izlaz
		begin
			desetice = shift[15:12];
			jedinice = shift[11:8];
			i = 0;
		end
   end
 
endmodule
