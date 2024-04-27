`timescale 1ns / 1ps

module tb_system_on_chip();

    reg clk;
    reg [1:0] agent_token;
    reg [127:0] plaintext;
    reg [127:0] key;
    reg start_encrypt;
    reg puf_response;
    wire [127:0] ciphertext;
    wire busy;
    wire done;
    wire done_latched;
    wire trojan_trigger;
    reg [15:0] clock_counter;
    reg reset;
    reg [31:0] aes_key_access_policy;
  	reg [31:0] aes_locked;

    // Instantiate the system_on_chip module
    system_on_chip soc(
        .clk(clk),
        .agent_token(agent_token),
        .plaintext(plaintext),
        .key(key),
        .start_encrypt(start_encrypt),
        .puf_response(puf_response),
        .ciphertext(ciphertext),
        .busy(busy),
        .done(done),
        .done_latched(done_latched),
        .trojan_trigger(trojan_trigger),
        .reset(reset),
      	.aes_key_access_policy(aes_key_access_policy),
      	.aes_locked(aes_locked)
    );

    // Clock generation
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end
  


    // Test sequence
    initial begin
      
          // Set the name of the dump file
    $dumpfile("testbench.vcd");
    
    // Dump all variables in the test bench
    $dumpvars(0, tb_system_on_chip);
      
        reset = 1;
        #10;
        reset = 0;
      	#10;
        // Initialize inputs
        plaintext = 128'h00112233445566778899aabbccddeeff; // Example plaintext
        key = 128'h000102030405060708090a0b0c0d0e0f; // Example key
        start_encrypt = 0;
        clock_counter = 0;
      	puf_response = 0;
      	#10;
      	

        // Test 1: Valid token, check trojan trigger effect
        agent_token = 2'b01; // Valid token
      $display("%t: Test 1 - Starting encryption with valid token. Policy: %h", $time, aes_key_access_policy);
        #20;
      	puf_response = 1;
        #10;
      	start_encrypt = 1;
        #10;
        start_encrypt = 0;
        #200;
      	
      // Enough time for the encryption to complete if not blocked
      $display ("aes_locked: %h, aes_key_access_policy: %h", aes_locked, aes_key_access_policy);
        if (done_latched) begin
            $display("%t: Test 1 Passed - Encryption completed with valid token.", $time);
        end else begin
            $display("%t: Test 1 Failed - Encryption did not complete with valid token.", $time);
        end
        $display("%t: Trojan status after encryption: %b", $time, trojan_trigger);

        // Test 2: Invalid token after Trojan triggered
      	puf_response = 0;
        agent_token = 2'b00; // Invalid token
      $display("%t: Test 2 - Attempting encryption with invalid token after Trojan activation. Policy: %h", $time, aes_key_access_policy);
        #10;
        start_encrypt = 1;
        #10; 
        start_encrypt = 0;
        #200; // Wait long enough to see if encryption attempts and fails
        if (!done_latched) begin
            $display("%t: Test 2 Passed - Encryption blocked as expected with invalid token.", $time);
        end else begin
            $display("%t: Test 2 Failed - Encryption should not have completed.", $time);
        end

        // Finish simulation
        #100;
        $finish;
    end

endmodule
