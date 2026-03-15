`timescale 1ns / 1ps

// TRANSPOSED FIR FILTER
module fir_filter #(parameter TAPS=128) (
    input signed [15:0] x,
    input [1:0] flt_type,
    input clk, rst, en,
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
    
    reg signed [39:0] z[0:ORDER-1]; // z delay blocks
    //reg signed [15:0] coeffs[0:TAPS-1]; // MATLAB generated coefficients
    wire signed [31:0] acc_out;
    
    reg signed [15:0] coeffs_LP[0:TAPS-1]; 
    reg signed [15:0] coeffs_HP[0:TAPS-1]; 
    reg signed [15:0] coeffs_BP[0:TAPS-1]; 
    reg signed [15:0] coeffs_BS[0:TAPS-1]; 
    reg signed [15:0] sel_coeffs[0:TAPS-1]; 
    
    wire signed [39:0] y_raw;
    wire signed [31:0] y_out;
    
    round_sat rs1 (.acc(y_raw), .y_out(y_out));
    
    integer i;
    initial begin
        for(i = 0; i < ORDER; i = i + 1)
            z[i] = 40'b0;
        //load the coefficients from memory
        $readmemh("LP_coeffs_8000Hz_128taps.txt", coeffs_LP);
        $readmemh("HP_coeffs_8000Hz_128taps.txt", coeffs_HP);
        $readmemh("BP_coeffs_4000Hz_8000Hz_128taps.txt", coeffs_BP);
        $readmemh("BS_coeffs_4000Hz_8000Hz_128taps.txt", coeffs_BS);    
    end
    
    assign y_raw = (sel_coeffs[0] * x) + z[0];
    
    integer m;
    always @(*) begin
        case(flt_type)
            2'b00: for(m = 0; m < TAPS; m = m + 1) sel_coeffs[m] = coeffs_LP[m];
            2'b01: for(m = 0; m < TAPS; m = m + 1) sel_coeffs[m] = coeffs_HP[m];
            2'b10: for(m = 0; m < TAPS; m = m + 1) sel_coeffs[m] = coeffs_BP[m];
            2'b11: for(m = 0; m < TAPS; m = m + 1) sel_coeffs[m] = coeffs_BS[m];
            default: for(m = 0; m < TAPS; m = m + 1) sel_coeffs[m] = coeffs_LP[m];
        endcase
    end
    
    integer k;
    always @(posedge clk) begin
        if(rst) begin
            y <= 32'b0;
            for(k = 0; k < ORDER; k = k + 1)
                z[k] <= 40'b0;
        end
        
        else if(en) begin
            y <= y_out;
            z[ORDER-1] <= sel_coeffs[TAPS-1] * x; // z[126] = coeffs[127] * x
            for(k = 0; k < ORDER-1; k = k + 1) // k goes from 0 to 125, ORDER-1 = 126
                z[k] <= (sel_coeffs[k+1]*x) + z[k+1];
        end
    end 
     
endmodule
