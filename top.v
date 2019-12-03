`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/10/13 20:17:17
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    clk
//    ,ena
//    ,wea
//    ,ifm_addr
//    ,weight_addr
    ,dina
    ,result);

input clk;
//input ena;
//input wea;
input [63:0] dina;
output [15:0] result;
wire [7:0] mm;
wire [7:0] rr;
wire [7:0] cc;
wire [7:0] nn;
wire [3:0] ii;
wire [3:0] jj;
wire [15:0] ifm_addr;
wire [15:0] weight_addr;
wire [15:0] out_addr;
wire w_ena;
wire in_ena;
wire o_ena;  // suspended, replaced by wr_rdy
wire wea;
wire [7:0] out_wea;
<<<<<<< HEAD
wire [63:0] ifm_dout;							//These are neightbor data in middle layers, 
wire [63:0] weight_dout;						//doesn't have any significance, just random values.
=======

//----------- data -----------------//
wire [63:0] ifm_dout;
wire [63:0] weight_dout;
>>>>>>> master
wire [15:0] ifm_0, ifm_1,ifm_2,ifm_3;
wire [15:0] w_0, w_1,w_2,w_3;
wire [15:0] product_0,product_1,product_2,product_3;



wire [63:0] psum_pkd;
wire [63:0] dout; // suspended wire, any problem?

//----------------  signals for write control----------------//

wire neuron_rdy;
wire plane_rdy;
wire clear;
wire [15:0] sum;

wire layer_ready;
assign result = sum;
assign clear = neuron_rdy;

loop for_loop(
    .clk(clk),
    .m(mm),
    .r(rr),
    .c(cc),
    .n(nn),
    .i(ii),
    .j(jj),
    .layer_ready(layer_ready)
    );
    
controller ctl(
    .clock(clk),
    .m(mm),
    .r(rr),
    .c(cc),
    .n(nn),
    .i(ii),
    .j(jj),
    .ifm_addr(ifm_addr),
    .weight_addr(weight_addr),
//    .out_addr(out_addr),
    .weight_ena(w_ena),
    .input_ena(in_ena),
    .out_ena(o_ena),
    .wea(wea),
    .out_wea(out_wea));
    
blk_mem_input ifm_buf (
  .clka(clk),    								// input wire: clock
  .ena(in_ena),      							// input wire: total enable
  .wea(wea),      								// input wire: [0 : 0] write enable
  .addra(ifm_addr),  							// input wire: [7 : 0] image feature map address
  .dina(dina),   								// input wire: [63 : 0] write value,useless(don't need to write,wea always 0!)
  .douta(ifm_dout)  							// output wire: [63 : 0]  read value(image feature map value)
);

blk_mem_weight weight_buf (
  .clka(clk),    								// input wire: clock
  .ena(w_ena),      							// input wire: total enable
  .wea(wea),      								// input wire: [0 : 0] write enable
  .addra(weight_addr),  						// input wire: [7 : 0] weight address 
  .dina(dina),    								// input wire: [63 : 0] write value,useless(don't need to write, wea always 0!)
  .douta(weight_dout)  							// output wire: [63 : 0] read value(weight value)
);

assign ifm_0 = ifm_dout[63:48];
assign ifm_1 = ifm_dout[47:32];
assign ifm_2 = ifm_dout[31:16];
assign ifm_3 = ifm_dout[15:0];

assign w_0 = weight_dout[63:48];
assign w_1 = weight_dout[47:32];
assign w_2 = weight_dout[31:16];
assign w_3 = weight_dout[15:0];

//assign dout_0 = dout[63:48];
//assign dout_1 = dout[47:32];
//assign dout_2 = dout[31:16];
//assign dout_3 = dout[15:0];
    
mac inst(
    .clk(clk),
    .ifm_0(ifm_0),
    .ifm_1(ifm_1),
    .ifm_2(ifm_2),
    .ifm_3(ifm_3),
    .w_0(w_0),
    .w_1(w_1),
    .w_2(w_2),
    .w_3(w_3),
    .product_0(product_0),
    .product_1(product_1),
    .product_2(product_2),
    .product_3(product_3)
    );

acc accumulator(
    .clk(clk),
    .in_0(product_0),
    .in_1(product_1),
    .in_2(product_2),
    .in_3(product_3),
    .clear(clear),
    .sum(sum)
   
    );

neu_rdy neuron_ok(
    .in(w_3),
    .neuron_rdy(neuron_rdy),
    .out_addr(out_addr));
    
plane_rdy plane_ok(
    .in(neuron_rdy),
    .plane_rdy(plane_rdy));           
    
    
out_mux sel_channel(
    .sel(plane_rdy),
    .din(sum),
    .psum_pkd(psum_pkd));   
    
blk_mem_output out_buf(
    .clka(clk),
    .ena(neuron_rdy),
    .wea(out_wea),
    .addra(out_addr),
    .dina(psum_pkd),
    .douta(dout));
    
endmodule
