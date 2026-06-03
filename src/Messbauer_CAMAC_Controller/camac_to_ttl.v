module camac_to_ttl #(
    parameter N=1)
(
    input  wire [N-1:0] i,
    output wire [N-1:0] o 
);

assign o = ~i;
 
endmodule
