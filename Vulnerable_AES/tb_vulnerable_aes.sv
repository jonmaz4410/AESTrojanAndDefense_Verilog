`timescale 1ns / 1ps

module tb_system_on_chip();

    reg clk;
    reg [1:0] agent_token;
    reg [127:0] plaintext;
    reg [127:0] key;
    reg start_encrypt;
    wire [127:0] ciphertext;
    wire busy;
    wire done;
  	wire done_latched;

    // Instantiate the system_on_chip module
    system_on_chip soc(
        .clk(clk),
        .agent_token(agent_token),
        .plaintext(plaintext),
        .key(key),
        .start_encrypt(start_encrypt),
        .ciphertext(ciphertext),
        .busy(busy),
      	.done(done),
      	.done_latched(done_latched)
    );

    // Clock generation
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    // Test sequence
    initial begin
        // Initialize inputs
        agent_token = 2'b00; // Invalid token
        plaintext = 128'h00112233445566778899aabbccddeeff; // Example plaintext
        key = 128'h000102030405060708090a0b0c0d0e0f; // Example key
        start_encrypt = 0;

        // Wait for global reset to finish
        #20;
        $display("%t: Starting test with invalid user token...", $time);

        // Attempt to access and perform encryption with invalid user
        start_encrypt = 1;
        $display("%t: Triggered start_encrypt with invalid token.", $time);
        #10; 
        start_encrypt = 0;
        #200; // Adjust this wait time to allow for the two cycles per round
        $display("%t: Finished attempt with invalid token. Busy: %b, Done: %b", $time, busy, done);
      	if (done_latched) begin
            $display("%t: Encryption with valid user completed.", $time);
        end else begin
            $display("%t: Encryption not completed or started by invalid user.", $time);
        end

        // Change the token to a valid one (agent 1)
        agent_token = 2'b01; // Valid token
        #10;
        $display("%t: Changed token to valid user.", $time);

        // Attempt to access and perform encryption with valid user

        start_encrypt = 1;
        $display("%t: Triggered start_encrypt with valid token.", $time);
        #10; 
        start_encrypt = 0;
        #200; // Wait long enough for the encryption to complete
        $display("%t: Finished attempt with valid token. Busy: %b, Done: %b", $time, busy, done);

      if (done_latched) begin
            $display("%t: Encryption with valid user completed.", $time);
        end else begin
          $display("%t: Encryption not completed or started by valid user.", $time);
        end

        // Finish simulation
        $finish;
    end

endmodule
