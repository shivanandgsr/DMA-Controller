//Project : Design and Verification of                 //
//			8237A-5 DMA Controll                       //																				    
//													   //															
// Subject:	ECE 571									   //										                        																															    
// Guide  : Mark Faust   							   //													            
// Date   : March 12, 2021							   //																		
// Team	  :	Shivanand Reddy Gujjula,                   //
//			Sri Harsha Doppalapudi,                    //
//			Jayashree Bodavula,	                       //
//			Sameer Shaik							   //																										
// Portland State University                           //  
//                                                     //                                                     //
/////////////////////////////////////////////////////////

`include "test.sv"
module top;

	logic CLOCK,RESET;

	parameter NumRuns = 1;
	parameter CLOCK_CYCLE = 20;
	parameter CLOCK_WIDTH = CLOCK_CYCLE/2;

	ExternalBus Extr (CLOCK,RESET);
	DMATop DUT (Extr);
	AssertionsDMA assertionsdma(Extr);
	test #(NumRuns)DMATest (Extr);


	always #CLOCK_WIDTH CLOCK = !CLOCK;

	initial
	begin
		CLOCK = '0;
		RESET = '1;
		repeat(20)
		@(negedge CLOCK);
		RESET = '0;
	end
endmodule