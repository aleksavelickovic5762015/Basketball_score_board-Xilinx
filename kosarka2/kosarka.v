`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:17:00 01/28/2017 
// Design Name: 
// Module Name:    kosarka 
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
module kosarka(
		input clk,																				// Klok
		input b0,b1,b2,b3,																	// Cetiri tastera
		input p0,p1,p2,																		// Tri prekidaca
		output a,b,c,d,e,f,g,dp,															// Sedam segmenata displeja i tacka
		output [3:0] an																		// Cetvorocifreni displej
    );

reg clkD=0,clkV=0;																			// Clock disleja, clock vremena	
reg [16:0] brojacD=0;																		// Brojac displeja
reg [28:0] brojacV=0;																		// Brojac vremena

reg [7:0] vremeA=40,vremeB=0,rezulA=0,rezulB=0;										// Pocetak utakmice 40min, 0sec, rezultat ekipaA 0, ekipaB 0

reg [3:0] displej = 4'b0110;																// Broj koji se trenutno ispisuje na displeju
reg [6:0] s_seg = 0;																			// Sedmosegmentna kombinacija
reg [3:0] cifra = 4'b1110;																	// Koja od cetiri cifre je trenutno upaljena

reg stop = 1'b1;																				// Zaustavlja vreme
wire [3:0] vremeAdesetice, vremeAjedinice, vremeBdesetice, vremeBjedinice;	// BCD oblik za vremeA i vremeB
wire [3:0] rezulAdesetice, rezulAjedinice, rezulBdesetice, rezulBjedinice;	// BCD oblik za rezulA i rezulB

wire b_0,b_1,b_2,b_3;																		// Za svaki taster je definicana zica
wire p_0,p_1,p_2;																				// Zice koje idu od prekidaca

//buttoni
assign b_0 = b0;
assign b_1 = b1;																				// Dodeljivanje vrednosti zicama svih tastera
assign b_2 = b2;
assign b_3 = b3;

//prekidaci
assign p_0 = p0;
assign p_1 = p1;																				// Zica uzima vrednost prekidaca
assign p_2 = p2;

reg stanjeB0 = 1'b0;
reg stanjeB1 = 1'b0;																			// Pamte da li je stisnut taster
reg stanjeB2 = 1'b0;
reg stanjeB3 = 1'b0;

bcd bcd_vremeA(clk, vremeA, vremeAdesetice, vremeAjedinice);
bcd bcd_vremeB(clk, vremeB, vremeBdesetice, vremeBjedinice);					// Iz binarnog u BCD oblik
bcd bcd_rezulA(clk, rezulA, rezulAdesetice, rezulAjedinice);
bcd bcd_rezulB(clk, rezulB, rezulBdesetice, rezulBjedinice);

always @(posedge clk)
	begin
		if(brojacD==25000)																	// Inkrementuje do 25000, jer je clk ploce 50MHz
		begin
			clkD = ~clkD;																		// clkD 1kHz
			brojacD=0;
		end
		brojacD = brojacD+1;
			
		if(brojacV==25000000)																// Inkrementuje do 25000000, hiljadu puta sporije od clkD
		begin
			clkV = ~clkV;																		// clkV 1Hz
			brojacV=0;
		end
		brojacV = brojacV+1;
		
		case(displej)
			4'd0 : s_seg = 7'b1000000; 													// 0
			4'd1 : s_seg = 7'b1111001; 													// 1
			4'd2 : s_seg = 7'b0100100; 													// 2
			4'd3 : s_seg = 7'b0110000; 													// 3
			4'd4 : s_seg = 7'b0011001; 													// 4
			4'd5 : s_seg = 7'b0010010; 													// 5
			4'd6 : s_seg = 7'b0000010; 													// 6
			4'd7 : s_seg = 7'b1111000; 													// 7
			4'd8 : s_seg = 7'b0000000; 													// 8
			4'd9 : s_seg = 7'b0010000; 													// 9
			default : s_seg = 7'b1000000; 												// 0
		endcase
	end
always @(posedge clkV)
	begin
		if(stop==0)																				// Ako nije zaustavljeno..
		begin
			if(vremeB==0)																		// Ako izbrojao 60 sekundi..
			begin
				vremeB = 59;																	// ..nov minut
				vremeA = vremeA-1;															// ..prosao je minut, dekrementuj
			end
			else
				vremeB = vremeB-1;															// Nastavlja da odborojava sekunde (ako nije prosao minut)
		end
	end
always @(posedge clkD)
	begin
		if(vremeA==0 && vremeB==0)															// Ako je istekla utakmica
				stop = 1;																		// ..zaustavi
		case({p_2,cifra})
			5'b00111: begin displej = vremeBjedinice; cifra = 4'b1110; end
			5'b01110: begin displej = vremeBdesetice; cifra = 4'b1101; end		// Ako je prekidac p2 = 0, prikazi vreme na displeju
			5'b01101: begin displej = vremeAjedinice; cifra = 4'b1011; end		// Smenjuje se trenutna "cifra" koja se prikazuje
			5'b01011: begin displej = vremeAdesetice; cifra = 4'b0111; end
			
			5'b10111: begin displej = rezulBjedinice; cifra = 4'b1110; end
			5'b11110: begin displej = rezulBdesetice; cifra = 4'b1101; end		// Ako je prekidac p2 = 1, prikazi rezultat na displeju
			5'b11101: begin displej = rezulAjedinice; cifra = 4'b1011; end
			5'b11011: begin displej = rezulAdesetice; cifra = 4'b0111; end
		endcase
		
		if(b_0 == 1'b1)
			stanjeB0 = 1'b1;																	// Stisnut je taster b0
		if(stanjeB0==1'b1 && b_0 == 1'b0)												// ..ako taster nije vise stisnut
		begin
			stop = ~stop;																		// ..zaustavlja/krece vreme
			stanjeB0 = 1'b0;																	// Izvrsena je namena tastera
		end
		
		if(b_1 == 1'b1)
			stanjeB1 = 1'b1;																	// Stisnut je taster b1
		if(stanjeB1==1'b1 && b_1 == 1'b0)												// ..ako taster nije vise stisnut
		begin
			case({p_1,p_0})
				2'b00: rezulB = rezulB+3;													// Taster b1 = +/- 3
				2'b01: rezulB = rezulB-3;													// Prekidac p1 odredjuje kojoj se ekipi dodeljuju bodovi
				2'b10: rezulA = rezulA+3;													// Prekidac p0, da li dodeljuju ili oduzimaju bodovi?
				2'b11: rezulA = rezulA-3;
			endcase
			stanjeB1 = 1'b0;																	// Izvrsena je namena tastera
		end
		if(b_2 == 1'b1)
			stanjeB2 = 1'b1;																	// Stisnut je taster b2
		if(stanjeB2==1'b1 && b_2 == 1'b0)												// ..ako taster nije vise stisnut
		begin
			case({p_1,p_0})
				2'b00: rezulB = rezulB+2;													// Taster b2 = +/- 2
				2'b01: rezulB = rezulB-2;													// Prekidac p1 odredjuje kojoj se ekipi dodeljuju bodovi
				2'b10: rezulA = rezulA+2;													// Prekidac p0, da li dodeljuju ili oduzimaju bodovi?
				2'b11: rezulA = rezulA-2;
			endcase
			stanjeB2 = 1'b0;																	// Izvrsena je namena tastera
		end
		if(b_3 == 1'b1)
			stanjeB3 = 1'b1;																	// Stisnut je taster b3
		if(stanjeB3==1'b1 && b_3 == 1'b0)												// ..ako taster nije vise stisnut
		begin
			case({p_1,p_0})
				2'b00: rezulB = rezulB+1;													// Taster b3 = +/- 1
				2'b01: rezulB = rezulB-1;													// Prekidac p1 odredjuje kojoj se ekipi dodeljuju bodovi
				2'b10: rezulA = rezulA+1;													// Prekidac p0, da li dodeljuju ili oduzimaju bodovi?
				2'b11: rezulA = rezulA-1;
			endcase
			stanjeB3 = 1'b0;																	// Izvrsena je namena tastera
		end
	end

assign an = cifra;

assign {g, f, e, d, c, b, a} = s_seg;													// Svaki segment uzima vrednost jednog bita "s_seg"-a
assign dp = 1'b1;																				// Ne koristi se decimalna tacka na displeju


endmodule	