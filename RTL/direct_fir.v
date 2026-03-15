`timescale 1ns / 1ps

module direct_fir #(parameter TAPS=128) (
    input signed [15:0] x,
    input [1:0] flt_type,
    input clk, rst, en,
    output reg signed [39:0] acc,
    output reg signed [31:0] y
    );
    
    /*
        flt_type:
            2'b00: low-pass filtering
            2'b01: high-pass filtering
            2'b10: band-pass filtering
            2'b11: band-stop filtering
    */
    
    localparam ORDER = TAPS - 1;
    
    reg signed [15:0] z[0:ORDER-1]; // z delay blocks
    //reg signed [15:0] coeffs[0:TAPS-1]; // MATLAB generated coefficients
    wire signed [31:0] acc_out;
    
    reg signed [15:0] coeffs_LP[0:TAPS-1]; 
    reg signed [15:0] coeffs_HP[0:TAPS-1]; 
    reg signed [15:0] coeffs_BP[0:TAPS-1]; 
    reg signed [15:0] coeffs_BS[0:TAPS-1]; 
    reg signed [15:0] sel_coeffs[0:TAPS-1]; 
    
    round_sat rs1 (.acc(acc), .y_out(acc_out));
    
    integer i;
    initial begin
        for(i = 0; i < ORDER; i = i + 1)
            z[i] = 16'b0;
        //load the coefficients from memory
        $readmemh("LP_coeffs_8000Hz_128taps.txt", coeffs_LP);
        $readmemh("HP_coeffs_8000Hz_128taps.txt", coeffs_HP);
        $readmemh("BP_coeffs_4000Hz_8000Hz_128taps.txt", coeffs_BP);
        $readmemh("BS_coeffs_4000Hz_8000Hz_128taps.txt", coeffs_BS);
    end
    
    integer k;
    always @ (*) begin
        /*case(flt_type)
            2'b00: for(m = 0; m < TAPS-1; m = m + 1) sel_coeffs[m] = coeffs_LP[m];
            2'b01: for(m = 0; m < TAPS-1; m = m + 1) sel_coeffs[m] = coeffs_HP[m];
            2'b10: for(m = 0; m < TAPS-1; m = m + 1) sel_coeffs[m] = coeffs_BP[m];
            2'b11: for(m = 0; m < TAPS-1; m = m + 1) sel_coeffs[m] = coeffs_BS[m];
            default: for(m = 0; m < TAPS-1; m = m + 1) sel_coeffs[m] = coeffs_LP[m];
        endcase*/
        
        case(flt_type)
            2'b00: begin
                acc = x * coeffs_LP[0];
                for(k = 1; k < TAPS; k = k + 1)
                    acc = acc + (coeffs_LP[k] * z[k-1]);
            end
            
            2'b01: begin
                acc = x * coeffs_HP[0];
                for(k = 1; k < TAPS; k = k + 1)
                    acc = acc + (coeffs_HP[k] * z[k-1]);
            end
            
            2'b10: begin
                acc = x * coeffs_BP[0];
                for(k = 1; k < TAPS; k = k + 1)
                    acc = acc + (coeffs_BP[k] * z[k-1]);
            end
            
            2'b11: begin
                acc = x * coeffs_BS[0];
                for(k = 1; k < TAPS; k = k + 1)
                    acc = acc + (coeffs_BS[k] * z[k-1]);
            end        
        endcase
    end
    
    integer m;
    always @ (posedge clk) begin
        if(rst) begin
            y <= 32'b0;
            for(m = 0; m < ORDER; m = m + 1)
                z[m] <= 16'b0;
        end 
        
        else if(en) begin
            for(m = ORDER-1; m > 0; m = m - 1)
                z[m] <= z[m-1];
                
            z[0] <= x;
            y <= acc_out;
        end
    end
    
endmodule
