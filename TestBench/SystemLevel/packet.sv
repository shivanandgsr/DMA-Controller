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

import DMApackage::*;  

class packet;

	randc bit [NumChannels-1:0] DREQ;	
	randc logic [DataBusWidth-1:0] data;
	randc logic [AddressBusWidth-1:0] address;
	
	rand bit [NumChannels-1:0][AddrWordCountWidth-1:0] BaseAddress;
	rand bit [NumChannels-1:0][AddrWordCountWidth-1:0] BaseWordCount;
	rand bit [NumChannels-1:0][AddrWordCountWidth-1:0] CurrentAddress;
	rand bit [NumChannels-1:0][AddrWordCountWidth-1:0] CurrentWordCount;

	randc  CommandRegister Command; 
	randc RequestRegister Request;
	randc bit [NumChannels-1:0]	Mask;
	randc ModeRegister [NumChannels-1:0] Mode;
	
	constraint NormTime_cb{Command.CmprdTime == '0;};// Normal timing
	constraint ContrDis_cb{Command.ContrDis  == '0;};// Controller Enable
	constraint MemToMem_cb{Command.MemToMem  == '0;};// Memory to Memory disable
	constraint LateExtWrite_cb{Command.LateExtWrite == '0;};
	
	constraint ModeRWV_cb	{foreach(Mode[i]) Mode[i].rwv inside{2'b01,2'b10};};// read or write only
	constraint ModeTmode_cb	{foreach(Mode[i]) Mode[i].Tmode inside{2'b01,2'b10};};// single transfer or Block transfer only
	
	constraint data_valid 	{data 	 inside{['0:(DataBusWidth-1)'(2**(DataBusWidth-1) - 1'b1)]}; };
	constraint address_valid{address inside{['0:(AddressBusWidth-1)'(2**(AddressBusWidth-1) - 1'b1)]};};
	
	constraint CurrentAddress_cb  {foreach(CurrentAddress[i])CurrentAddress[i] == BaseAddress[i];};
	constraint CurrentWordCount_cb{foreach(CurrentWordCount[i])CurrentWordCount[i]== BaseWordCount[i];};
	
endclass
/*
//------------------------------------------End of packet class------------------------------------
*/