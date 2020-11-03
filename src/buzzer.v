module buzzer (
    input clk,    // Clock 1MHz
    input clk_2,    // Clock 200Hz
    input rst_n,

    input en,
    
    output reg buzzer_out
);
    localparam COUNTER_BITS = 10;
    localparam CLOCK_FREQ = 1e6; // 1M

    reg [2:0] note_count;

    reg [COUNTER_BITS-1:0] freq_count;
    integer                freq_count_max_integer;
    reg [COUNTER_BITS-1:0] freq_count_max;

    reg [4:0] step_clock_count; // 200Hz->8Hz
    reg [1:0] step_count;

    wire next_step = (step_clock_count == 24);
    reg  next_step_r;
    wire next_note = (next_step_r && ~next_step && step_count == 0);

    integer note_id;

    always @(*) begin
        case (note_count)
            0: note_id = 21;
            1: note_id = 16;
            2: note_id = 14;
            3: note_id = 12;
            4: note_id = 9;
            5: note_id = 12;
            6: note_id = 14;
            7: note_id = 16;
            default: note_id = 0;
        endcase
        case (note_id)
            // rtoi is not supported by Quartus II
            0:  freq_count_max_integer = 956; // $rtoi(CLOCK_FREQ / 523.25 / 2); // C5, 1911/2
            1:  freq_count_max_integer = 902; // $rtoi(CLOCK_FREQ / 554.37 / 2); // C#5/Db5
            2:  freq_count_max_integer = 851; // $rtoi(CLOCK_FREQ / 587.33 / 2); // D5
            3:  freq_count_max_integer = 804; // $rtoi(CLOCK_FREQ / 622.25 / 2); // D#5/Eb5
            4:  freq_count_max_integer = 758; // $rtoi(CLOCK_FREQ / 659.25 / 2); // E5
            5:  freq_count_max_integer = 716; // $rtoi(CLOCK_FREQ / 698.46 / 2); // F5
            6:  freq_count_max_integer = 676; // $rtoi(CLOCK_FREQ / 739.99 / 2); // F#5/Gb5
            7:  freq_count_max_integer = 638; // $rtoi(CLOCK_FREQ / 783.99 / 2); // G5
            8:  freq_count_max_integer = 602; // $rtoi(CLOCK_FREQ / 830.61 / 2); // G#5/Ab5
            9:  freq_count_max_integer = 568; // $rtoi(CLOCK_FREQ / 880.00 / 2); // A5
            10: freq_count_max_integer = 536; // $rtoi(CLOCK_FREQ / 932.33 / 2); // A#5/Bb5
            11: freq_count_max_integer = 506; // $rtoi(CLOCK_FREQ / 987.77 / 2); // B5

            12: freq_count_max_integer = 478; // $rtoi(CLOCK_FREQ / 1046.50 / 2); // C6
            13: freq_count_max_integer = 451; // $rtoi(CLOCK_FREQ / 1108.73 / 2); // C#6/Db6
            14: freq_count_max_integer = 426; // $rtoi(CLOCK_FREQ / 1174.66 / 2); // D6
            15: freq_count_max_integer = 402; // $rtoi(CLOCK_FREQ / 1244.51 / 2); // D#6/Eb6
            16: freq_count_max_integer = 379; // $rtoi(CLOCK_FREQ / 1318.51 / 2); // E6
            17: freq_count_max_integer = 358; // $rtoi(CLOCK_FREQ / 1396.91 / 2); // F6
            18: freq_count_max_integer = 338; // $rtoi(CLOCK_FREQ / 1479.98 / 2); // F#6/Gb6
            19: freq_count_max_integer = 319; // $rtoi(CLOCK_FREQ / 1567.98 / 2); // G6
            20: freq_count_max_integer = 301; // $rtoi(CLOCK_FREQ / 1661.22 / 2); // G#6/Ab6
            21: freq_count_max_integer = 284; // $rtoi(CLOCK_FREQ / 1760.00 / 2); // A6
            22: freq_count_max_integer = 268; // $rtoi(CLOCK_FREQ / 1864.66 / 2); // A#6/Bb6
            23: freq_count_max_integer = 253; // $rtoi(CLOCK_FREQ / 1975.53 / 2); // B6
            default: freq_count_max_integer = -1;
        endcase
        freq_count_max = freq_count_max_integer[COUNTER_BITS-1:0];
    end

    always @(posedge clk or negedge rst_n) begin : proc_next_step_r
        if (~rst_n) begin
            next_step_r <= 0;
        end else begin
            next_step_r <= next_step;
        end
    end

    // wire rst_n_freq_count = rst_n && en && step_count != 3;
    always @(posedge clk or negedge rst_n) begin : proc_freq_count
        if(~rst_n) begin
            freq_count <= 0;
            buzzer_out <= 0;
        end else begin
            if (en/* && step_count != 3*/) begin
                if (freq_count == freq_count_max) begin
                    buzzer_out <= ~buzzer_out;
                    freq_count <= 0;
                end else begin
                    freq_count <= freq_count + 1'b1;
                end
            end else begin
                freq_count <= 0;
                buzzer_out <= 0;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin : proc_note_count
        if (~rst_n) begin
            note_count <= 0;
        end else begin
            if (~en) begin
                note_count <= 0;
            end else if (next_note) begin
                note_count <= note_count + 1'b1;
            end
        end
    end

    always @(posedge clk_2 or negedge rst_n) begin : proc_step_count
        if (~rst_n) begin
            step_count <= 0;
        end else begin
            if (~en) begin
                step_count <= 0;
            end else if (next_step) begin
                step_count <= step_count + 1'b1;
            end
        end
    end
    always @(posedge clk_2 or negedge rst_n) begin : proc_step_clock_count
        if (~rst_n) begin
            step_clock_count <= 0;
        end else begin
            if (~en || next_step) begin
                step_clock_count <= 0;
            end else begin
                step_clock_count <= step_clock_count + 1'b1;
            end
        end
    end
endmodule