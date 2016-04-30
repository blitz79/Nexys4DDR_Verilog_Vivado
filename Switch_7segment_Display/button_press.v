`timescale 1ns / 1ps
module button_press(CLK,BTNC,SW,LED,C,AN);
input  CLK, BTNC;
input [15:0] SW;
output reg [15:0] LED;
output [6:0] C;
output [7:0] AN;
reg in_disp;
wire clkslow;
//reg clkorig;

always @ (posedge CLK) begin
    if(BTNC==1) begin
        LED<=0;
        in_disp<=0;        
    end
    else begin
        LED <= SW;
        in_disp<=1;
    end
end
//---------------------module clock_div(clk_in,rst,clk_out);
    clock_div cd1(.clk_in(CLK),.rst(in_disp),.clk_out(clkslow));
//---------------------module seg_disp(clk,in,disp,c,an);
    seg_disp s1(.clk(clkslow),.in(LED),.disp(in_disp),.c(C),.an(AN));
    
endmodule

module seg_disp(clk,in,disp,c,an);
input clk,disp;
input [15:0] in;
output reg [6:0] c;
output reg [7:0] an;
reg [1:0] state;
wire [6:0] c1,c2,c3,c4;

always @ (posedge clk) begin
    if(disp==0) begin
        c<=7'b1000000;
        an<=8'b00000000;
        state<=2'd0;
    end
    else begin
        case(state)
            2'd0:   begin   an<=8'b11111110;    c<=c1;  state<=2'd1;    end
            2'd1:   begin   an<=8'b11111101;    c<=c2;  state<=2'd2;    end
            2'd2:   begin   an<=8'b11111011;    c<=c3;  state<=2'd3;    end
            2'd3:   begin   an<=8'b11110111;    c<=c4;  state<=2'd0;    end
            default:    state<=2'd0;
        endcase
    end
end
    //--------convert (clk,in,digit)
    convert ca(.clk(clk),.in(in[3:0]),.digit(c1));
    convert cb(.clk(clk),.in(in[7:4]),.digit(c2));
    convert cc(.clk(clk),.in(in[11:8]),.digit(c3));
    convert cd(.clk(clk),.in(in[15:12]),.digit(c4));
endmodule



module clock_div(clk_in,rst,clk_out);
input clk_in, rst;
output wire clk_out;
reg [14:0] count;
always @ (posedge clk_in) begin
    if(rst==0) begin
        count=0;
    end
    else begin
        count=count+1;
    end
end
assign clk_out=count[14];
endmodule

module convert (clk,in,digit);
input clk;
input [3:0] in;
output reg [6:0] digit;
always @ (posedge clk) begin
    case(in)
        4'd0    : digit = 7'b1000000;
        4'd1    : digit = 7'b1111001;
        4'd2    : digit = 7'b0100100;
        4'd3    : digit = 7'b0110000;
        4'd4    : digit = 7'b0011001;
        4'd5    : digit = 7'b0010010;
        4'd6    : digit = 7'b0000010;
        4'd7    : digit = 7'b1111000;
        4'd8    : digit = 7'b0000000;
        4'd9    : digit = 7'b0010000;
        4'd10   : digit = 7'b0001000;
        4'd11   : digit = 7'b0000011;
        4'd12   : digit = 7'b1000110;
        4'd13   : digit = 7'b0100001;
        4'd14   : digit = 7'b0000110;
        4'd15   : digit = 7'b0001110;
        default : digit = 7'b1111111;
    endcase
end
endmodule

