`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2026 17:07:50
// Design Name: 
// Module Name: convolution_2d
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


module convolution_2d#(parameter m=4,n=2)(
input clk,rst,
input [31:0]a,b,
input [3:0]padding,stride,
output reg [63:0]out,
output reg done
    );
 
reg [31:0]temp_a[0:m-1][0:m-1];
reg [31:0]temp_b[0:n-1][0:n-1];
reg [63:0]temp_psum[0:m-n][0:m-n];
reg [3:0]i,j,k,l;
reg [3:0]row,col;
reg [2:0]state,next_state;

always@(posedge clk)begin
    if(rst) begin
        out<=0;
        done<=0;
        state<=0;
        i<=0; j<=0;
        row<=0; col<=0;
        k<=0;l<=0;
    end
    
    else begin
        state<=next_state;
        case(state)
            3'd0: begin if(row<m && col<m) begin
                        temp_a[row][col]<=a;
                        out<=a;
                         end
                  else
                        temp_a[row][col]<=0;
                  if(col<m-1)
                        col<=col+1;
                  else begin
                        col<=0;
                        if(row<m-1)
                            row<=row+1;
                        else begin
                            row<=0;
                            col<=0;
                            end
                    end       
                    end
             3'd1: begin if(row<n && col<n) begin
                        temp_b[row][col]<=b;
                        out<=b;
                         end
                  else
                        temp_b[row][col]<=0;
                  if(col<n-1)
                        col<=col+1;
                  else begin
                        col<=0;
                        if(row<n-1)
                            row<=row+1;
                        else
                            begin
                            row<=0;
                            col<=0;
                            end
                    end       
                    end
             3'd2: begin
                       
                        k<=row;
                        l<=col;
                        end
             3'd3: begin
                   
                   if(i==0 && j==0) begin
                        temp_psum[row][col]<=temp_a[k+i][l+j]*temp_b[i][j];
                        end
                   else begin
                        temp_psum[row][col]<=temp_psum[row][col]+temp_a[k+i][l+j]*temp_b[i][j];
                        
                    end    
                   if(j<n-1) begin
                        j<=j+1;
                        
                        end
                   else begin
                        j<=0;
                      
                        if(i<n-1) begin
                            i<=i+1;
                          
                            end
                        else begin
                            i<=0;
                            j<=0;
                           
                            end
                   end
                   end   
             3'd4: begin
             
                        if(col<m-n)
                            col<=col+1;
                        else begin
                            col<=0;
                            if(row<m-n)
                                row<=row+1;
                            else
                                begin
                            row<=0;
                            col<=0;
                            end
                        end  
                        end 
             3'd5: begin 
                    done<=1;
                    out<=temp_psum[row][col];
                    if(col<m-n)
                        col<=col+stride;
                    else begin
                        col<=0;
                        if(row<m-n)
                            row<=row+stride;
                        else
                           begin
                            row<=0;
                            col<=0;
                            end
                    end 
                    end        
             3'd6: done<=0;      
    endcase
   end end 
   
   always@(*) begin
        next_state = state;
        case(state)
            3'd0: begin
                    if(row==m-1 && col==m-1)
                        next_state<=3'd1;
                    else
                        next_state<=3'd0;
            end
            3'd1: begin
                    if(row==n-1 && col==n-1)
                        next_state<=3'd2;
                    else
                        next_state<=3'd1;
            end
            3'd2: next_state<=3'd3;
            3'd3:begin
                    if(i==n-1 && j==n-1)
                        next_state<=3'd4;
                    else
                        next_state<=3'd3;
            end
            3'd4: begin 
                  if(row==m-n && col==m-n)
                       next_state = 3'd5;
                  else
                       next_state = 3'd2;
                end
            3'd5: begin
                    if(row==m-n && col==m-n)
                        next_state<=3'd6;
                    else
                        next_state<=3'd5;
                     end
            3'd6:  next_state<=3'd6;
            default: next_state<=3'd0;
   endcase
   end
   
endmodule
