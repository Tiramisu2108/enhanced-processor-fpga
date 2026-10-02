library verilog;
use verilog.vl_types.all;
entity top_module is
    port(
        CLOCK_50        : in     vl_logic;
        KEY             : in     vl_logic_vector(0 downto 0);
        SW              : in     vl_logic_vector(9 downto 9);
        LEDR            : out    vl_logic_vector(9 downto 0)
    );
end top_module;
