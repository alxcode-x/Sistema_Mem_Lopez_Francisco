module Memory_System
#
(	
	parameter MEMORY_DEPTH 	= 64,
	parameter DATA_WIDTH 	= 32
)(
	input [31:0] Instruction_Range_i,
	input clk,
	input Write_Enable_i,
	input [(DATA_WIDTH-1):0] Write_Data_i,
	input [(DATA_WIDTH-1):0] Address_i,
	
	output [(DATA_WIDTH-1):0] Instruction_o
);
	// wires to save phisical instruction
	wire [(DATA_WIDTH-1):0] ph_Instruction_rom;
	wire [(DATA_WIDTH-1):0] ph_Instruction_ram;
	//Wire to save priority
	wire [1:0] Enable;
	// wires to save inputs
	wire [(DATA_WIDTH-1):0] Address_i_rom;
	wire [(DATA_WIDTH-1):0] Address_i_ram;
	// wires to save outputs
	wire [(DATA_WIDTH-1):0] Instruction_o_rom;
	wire [(DATA_WIDTH-1):0] Instruction_o_ram;

	
	// Priority Decoder
	Priority_Decoder PD(
		.Instruction_Range_i(Instruction_Range_i),
		.Enable_o(Enable));

	
	//===== ROM =================================
	// Decoder
	Instruction_Decoder #(
		.DATA_WIDTH(DATA_WIDTH))
	ROM_DECODER(
		.SUBSTRACT(Instruction_Range_i),
		.v_inst_i(Address_i),
		.ph_inst_o(ph_Instruction_rom));
	
	//ROM
	Program_Memory #(
		.MEMORY_DEPTH(MEMORY_DEPTH),
		.DATA_WIDTH(DATA_WIDTH))
	ROM(
		.Address_i(ph_Instruction_rom),
		.Instruction_o(Instruction_o_rom));
	
	//===== RAM =================================
	// Decoder
	Instruction_Decoder #(
		.DATA_WIDTH(DATA_WIDTH))
	RAM_DECODER(
		.SUBSTRACT(Instruction_Range_i),
		.v_inst_i(Address_i),
		.ph_inst_o(ph_Instruction_ram));
		
	// RAM
	Data_Memory #(
		.MEMORY_DEPTH(MEMORY_DEPTH),
		.DATA_WIDTH(DATA_WIDTH))
	RAM
	(
		.clk(clk),
		.Write_Enable_i(Write_Enable_i),
		.Write_Data_i(Write_Data_i),
		.Address_i(ph_Instruction_ram),
		.Instruction_o(Instruction_o_ram));

	//==== MUX =================================
	Memory_MUX 
	#(
		.DATA_WIDTH(DATA_WIDTH))
	MUX(
		.Selector(Instruction_Range_i),
		.Ram_i(Instruction_o_ram), 
		.Rom_i(Instruction_o_rom),
		.Instruction_o(Instruction_o));	
	
			
endmodule 