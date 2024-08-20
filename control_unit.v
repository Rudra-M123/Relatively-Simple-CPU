module control_unit(input clk, input reset);
    //registers 
    reg [7:0] IR;
    reg [7:0] AC;
    reg [7:0] DR, DR_out;
    reg [7:0] TR;
    reg [7:0] R;
    reg [15:0] PC;
    reg [15:0] AR;
    reg Zflag;

    reg [5:0] state;
    parameter 
        FETCH1 = 6'h01,
        FETCH2 = 6'h02,
        FETCH3 = 6'h03,
        NOP1 = 6'h00,
        LDAC1 = 6'h04,
        LDAC2 = 6'h05,
        LDAC3 = 6'h06,
        LDAC4 = 6'h07,
        LDAC5 = 6'h09,
        STAC1 = 6'h08,
        STAC2 = 6'h0A,
        STAC3 = 6'h0B,
        STAC4 = 6'h0D,
        STAC5 = 6'h0E,
        MVAC1 = 6'h0C,
        MOVR1 = 6'h10,
        JUMP1 = 6'h14,
        JUMP2 = 6'h0F,
        JUMP3 = 6'h11,
        JMPZ1 = 6'h18,
        JPNZ1 = 6'h1C,
        JMPN1 = 6'h12,
        JMPN2 = 6'h13,
        ADD1 = 6'h20,
        SUB1 = 6'h24,
        INAC1 = 6'h28,
        CLAC1 = 6'h2C,
        AND1 = 6'h30,
        OR1 = 6'h34,
        XOR1 = 6'h38,
        NOT1 = 6'h3C,
        ZLD1 = 6'h15;
    
    reg [17:0] microcoded_memory [0:63];
    reg [17:0] microcode;
    
    initial begin 
        $readmemh("microcoded_memory.txt", microcoded_memory);
        state <= NOP1;
        
        PC <= 16'h00; // boot address (NOP1 state)
        AR <= 16'hz;
        AC <= 8'h00;
        DR <= 8'h00;
        DR_out <= 8'h00;
        IR <= 8'h00;
        TR <= 8'h00;
        R <= 8'h00;
		Zflag <= 1'b1;
    end

    wire [1:0] BT;
    wire [3:0] M1;
    wire [2:0] M2; 
    wire [1:0] M3;    
    wire [5:0] ADDR;

    assign BT = microcode[17:16];
    assign M1 = microcode[15:12];
    assign M2 = microcode[10:8];
    assign M3 = microcode[7:6];
    assign ADDR = microcode[5:0];

    //microsequencer
    always @(posedge clk) begin
        $display("[%0t] AR: %hH, PC: %hH, DR: %hH, TR: %hH, IR: %hH, R: %hH, AC: %hH, Z: %b \n", $time, AR, PC, DR, TR, IR, R, AC, Zflag);
        state <= BT[1]?
            ((IR[7:4] == 4'h0)?
                {IR[3:0], 2'b00} : //IR map bc instruction here
                NOP1 //Nothing bc data here
            ) : 
            (BT[0]? //Continue to next state
                ADDR :
                ((~Zflag && state==JPNZ1) || (Zflag && state==JMPZ1))? //Conditional Jump
                    JUMP2 :
                    JMPN1
            );

        case(state)
            FETCH1: $display("FETCH1");
            FETCH2: $display("FETCH2");
            FETCH3: $display("FETCH3");
            default: $display("Instruction state");
        endcase

		DR_out <= DR;
    end

    always @(*) microcode <= microcoded_memory[state];

    //reset circuitry
    always @(reset) begin
        PC <= 16'h00; // boot address (NOP1 state)
        AR <= 16'hz;
        AC <= 8'h00;
        DR <= 8'h00;
        DR_out <= 8'h00;
        IR <= 8'h00;
        TR <= 8'h00;
        R <= 8'h00;
        Zflag <= 1'b1;

        state <= NOP1;
    end    

    wire [24:0] control_signals;

    assign control_signals[0] = M3==2'd1; //READ + MEMBUS
    assign control_signals[1] = M1==4'd5; //WRITE + BUSMEM
    assign control_signals[2] = M1==4'd3 || M3==2'd2; //ARLOAD
    assign control_signals[3] = M1==4'd1; //ARINC
    assign control_signals[4] = M1==4'd4; //PCLOAD
    assign control_signals[5] = M2==3'd1; //PCINC
    assign control_signals[6] = M3==2'd2; //PCBUS
    assign control_signals[7] = M1==4'd6 || M3==2'd1; //DRLOAD
    assign control_signals[8] = M1==4'd3 || M1==4'd4; //DRHBUS
    assign control_signals[9] = M1==4'd5 || M1==4'd8; //DRLBUS
    assign control_signals[10] = M1==4'd2;//TRLOAD
    assign control_signals[11] = control_signals[8]; //TRBUS
    assign control_signals[12] = M2==3'd2; //IRLOAD
    assign control_signals[13] = M1==4'd7; //RLOAD
    assign control_signals[14] = M1==4'd9 || M1==4'd10 || M1==4'd11 || M1==4'd14 || M1==4'd15 || M2==3'd3; //RBUS
    assign control_signals[15] = M1==4'd10 || M1==4'd11 || M1==4'd12; //ALUS1
    assign control_signals[16] = M1==4'd11; //ALUS2
    assign control_signals[17] = M1==4'd8 || M1==4'd9 || M1==4'd10; //ALUS3
    assign control_signals[18] = M1==4'd11 || M1==4'd12; //ALUS4
    assign control_signals[19] = M2==3'd3 || M2==3'd4; //ALUS5
    assign control_signals[20] = M1==4'd15 || M2==3'd4; //ALUS6
    assign control_signals[21] = M1==4'd14 || M1==4'd15 || M2==3'd3 || M2==3'd4; //ALUS7
    assign control_signals[22] = M1==4'd8 || M1==4'd9 || M1==4'd10 || M1==4'd11 || M1==4'd12 || M1==4'd13 || M1==4'd14 || M1==4'd15 || M2==3'd3 || M2==3'd4; //ACLOAD
    assign control_signals[23] = M1==4'd6 || M1==4'd7; //ACBUS
    assign control_signals[24] = M3==2'd3; //ZLOAD

	wire [7:0] busL, busH, ALU_out;
    wire [15:0] bus;

    //register updates
    always @(negedge clk) begin
        $display("[%0t] AR: %hH, PC: %hH, DR: %hH, TR: %hH, IR: %hH, R: %hH, AC: %hH, Z: %b", $time, AR, PC, DR, TR, IR, R, AC, Zflag);
        AR <= control_signals[2]? bus : (control_signals[3]? AR+1 : AR);
        PC <= control_signals[4]? bus : (control_signals[5]? PC+1 : PC);
        TR <= control_signals[10]? DR_out : TR;
        IR <= control_signals[12]? DR_out : IR;
        DR <= control_signals[7]? busL : DR;
        R <= control_signals[13]? busL : R;
        AC <= control_signals[22]? ALU_out : AC;
        Zflag <= control_signals[24]? ~|AC : Zflag;
    end

	wire [7:0] MEM_in, MEM_out;

    //ALU things
    alu alu0 ( .bus_in(busL), .AC_in(AC), .ALUSEL(control_signals[21:15]), .ALU_out(ALU_out));
    assign busL =
		(control_signals[0])? MEM_out :
		(control_signals[6])? PC[7:0] :
		(control_signals[9])? DR_out : 
		(control_signals[11])? TR :
		(control_signals[14])? R :
		(control_signals[23])? AC : 8'bz;

    assign busH =
		(control_signals[6])? PC[15:8] : 
		(control_signals[8]? DR_out : 8'bx);
    assign bus = {busH, busL};

	assign MEM_in = busL;

    memory mem0 ( .addr(AR), .WRITE(control_signals[1]), .READ(control_signals[0]), .data_in(MEM_in), .data_out(MEM_out) );
endmodule