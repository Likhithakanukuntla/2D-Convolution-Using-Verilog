`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2026 16:36:29
// Design Name: 
// Module Name: img_2d
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


module img_2d(
input clk,clkb,rst,
input [7:0]in,

output reg [31:0]out,
output reg wen1,wen2,wen3,
output reg [7:0]addr,
output  [7:0] b1_out, b2_out, b3_out,
output reg[3:0]state,
output reg [7:0] shifting_count,
output reg valid_in,done_store,write


    );
 
wire signed [7:0]filter[0:8];
reg [1:0] i,j;   
reg signed [31:0]temp;
reg [7:0] data_2to1,data_3to2;  
reg start;
reg [7:0]cnt;
reg [3:0]next_state;

wire [7:0] b1_in=done_store?data_2to1:in;
wire [7:0] b2_in=done_store?data_3to2:in;

localparam  START=4'd0 , STORE_IN=4'd1,STORING_DONE=4'd2, ADDR=4'd3,MAC=4'd4,HOLD=4'd5,
                STOP_WRITING=4'd6,EMPTY=4'd7,SHIFTING=4'd8,READ=4'd9,DONE=4'd10,END=4'd11;

 blk_mem_gen_0 B1(clkb, 1'b1, wen1, addr,b1_in, b1_out); 
 blk_mem_gen_0 B2(clkb, 1'b1, wen2, addr,b2_in, b2_out); 
 blk_mem_gen_0 B3(clkb, 1'b1, wen3, addr, in, b3_out);

assign filter[0]=1; assign filter[1]=2; assign filter[2]=1;
assign filter[3]=2; assign filter[4]=4; assign filter[5]=2;
assign filter[6]=1; assign filter[7]=2;assign filter[8]=1;

always @(posedge clk)begin
if(rst) begin
        wen1<=0;
        wen2<=0;
        wen3<=0;
        i<=0;j<=0;
        state <= 0;
        shifting_count<=0;
        valid_in<=0;
        done_store<=0;
        write<=0;
        addr<=0;
        cnt<=0;        
        out<=0;
        start<=0;
        temp<=0;
        end
        
    else begin 
        state<=next_state;
        addr<=cnt;
        case(state)
            START:begin
                    valid_in<=1;
                    wen1<=1;
                    end
            STORE_IN :begin if(addr==255)begin
                     if(wen1) begin
                            wen1<=0;
                            wen2<=1;
                            wen3<=0;
                            end
                     else if(wen2) begin
                            wen1<=0;
                            wen2<=0;
                            wen3<=1; 
                            end 
                    else begin
                            wen1<=0;
                            wen2<=0;
                            wen3<=0; 
                            end 
                            end
                   else if(cnt==255 && wen3==1)  valid_in<=0;
                           
                   else valid_in<=1;
                   
                   cnt<=cnt+1;
                   end
                   
              STORING_DONE:begin
                     cnt<=0;
                     wen1<=0;
                     wen2<=0;
                     wen3<=0;
                     done_store<=1;  
                      end
             ADDR: begin
                       if(j==0) begin
                            temp<=0;
                            if(temp < 0)
                        out <= -temp;
                    else
                        out <= temp;

                            end
                         
                       if(write )  write <=0;
                       if(j==2 && cnt<255) cnt<=cnt-1;
                       else 
                            cnt=cnt+1;
                    end
             MAC: begin
                        temp<=temp+ $signed(b1_out)*filter[0+j] + $signed( b2_out)*filter[3+j] + $signed(b3_out)*filter[6+j];
                        
                        if(addr>0 && j==0) write <=1;
                        start<=1;
                        if(j==2) begin
                            j<=0;
                            //write <=1;
                         end
                         else begin
                                j<=j+1;
                              //  write <=0;
                                end
                            
                    end  
             HOLD:  begin
                        write <=1;
                        cnt<=0;
                    end
             STOP_WRITING: begin
                        write<=0;
                        wen1<=0;
                        wen2<=0;
                        wen3<=0;
                        valid_in<=0;
                       shifting_count<= shifting_count+1; 
                   end
             EMPTY:    begin 
                        valid_in<=1;
                      end
             SHIFTING: begin
                        data_2to1<=b2_out;
                        data_3to2<=b3_out;
                        valid_in<=0;
                        wen1<=1;
                        wen2<=1;
                        wen3<=1;
                        cnt<=cnt+1;
                        end
             READ: begin           
                    wen1<=0;
                    wen2<=0;
                    wen3<=0;
                    valid_in<=0;
                    j<=0;
                    start<=0;
                    end
            DONE: valid_in<=1;
            END: begin end
            
            endcase
            end
            end
                                                
  always @(*) begin
  case(state)
        START: next_state=STORE_IN;
        STORE_IN: begin
                if(cnt==255 && wen3==1) next_state=STORING_DONE;
               
                else next_state=STORE_IN;
                end
        STORING_DONE: begin
                if(done_store) next_state=ADDR;
                else next_state=STORING_DONE;
                end
       ADDR:  begin
                if(addr==0 && start==1) next_state=HOLD;
                else next_state=MAC;
                end              
        MAC:   next_state=ADDR;
        HOLD:   next_state=STOP_WRITING;  
        STOP_WRITING:   begin
                if(shifting_count==253) next_state=END;
                else next_state=EMPTY;
                end 
        EMPTY:    next_state=SHIFTING; 
        SHIFTING:  next_state=READ; 
        READ: begin
                if(addr>=255) next_state=ADDR;
                else next_state=DONE;
                end 
       DONE:    next_state=SHIFTING; 
        END:    next_state=END;  
        default:  next_state=START; 
        endcase
        end                  
            

endmodule
