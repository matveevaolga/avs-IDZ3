.include "my_macrolib.s"

.eqv    INPUT_BUFFER_SIZE 512
.eqv    OUTPUT_BUFFER_SIZE 512
.eqv    ASCII_START 32
.eqv    ASCII_END 126
.eqv    ASCII_RANGE 95 #(ASCII_END - ASCII_START + 1)

.data
input_buffer:  .space INPUT_BUFFER_SIZE      # Buffer for input string
output_buffer: .space OUTPUT_BUFFER_SIZE      # Buffer for output result
frequency:     .space 380                     # 95 * 4, Frequency array for characters from 32 to 126
output_msg:    .asciz "%c: %d\n"

.text
main:
    # Read string from input file
    print_string("Enter the path to the input file: ")
    get_path(input_buffer, INPUT_BUFFER_SIZE) # Read file name
    open(input_buffer, 0)                     # Open file for reading
    li t5, -1
    beq a0, t5, file_open_error               # Check for successful file opening

    # Initialize frequency array
    la s0, frequency                          # Address of frequency array
    li s1, 0                                  # Index for frequency array
init_frequency:
    li t5, ASCII_RANGE
    bge s1, t5, read_line                    # If initialization is complete, go to reading line
    sw zero, 0(s0)                           # Initialize frequency to zero
    addi s0, s0, 4                            # Increment address by 4 bytes
    addi s1, s1, 1                            # Increment index
    j init_frequency                          # Repeat loop

read_line:
    allocate(INPUT_BUFFER_SIZE)               # Allocate memory for buffer
    mv a1, a0                                 # Save file descriptor
    read(a1, input_buffer, INPUT_BUFFER_SIZE) # Read string
    li t5, -1
    beq a0, t5, file_read_error               # Check for successful read
    la s2, input_buffer                       # Index for input string

next_char:
    lb t0, (s2)                               # Load next character
    beq t0, zero, write_results               # If end of string, go to writing results
    li t5, ASCII_START
    blt t0, t5, next_char                     # Ignore non-printable characters
    li t5, ASCII_END
    bgt t0, t5, next_char                     # Ignore non-printable characters

    la t1, frequency
    # Increase frequency of the corresponding character
    addi t1, t0, -ASCII_START                 # Shift index for frequency array
    slli t1, t1, 2                            # Multiply by 4
    lw t2, (t1)                               # Get frequency of current character
    addi t2, t2, 1                            # Increment counter
    sw t2, (t1)                               # Save back to array
    addi s2, s2, 1                            # Move to next character
    j next_char                                # Return to character reading

write_results:
    print_string("Enter the path to the output file: ")
    get_path(input_buffer, INPUT_BUFFER_SIZE)   # Read file name for writing
    open(input_buffer, 1)                       # Open file for writing
    li t5, -1
    beq a0, t5, file_open_error                # Check for successful file opening

    # Prompt to output results to console
    print_string("Do you want to print results to console? (Y/N): ")
    get_path(input_buffer, INPUT_BUFFER_SIZE)   # Read user response
    li t6, 'Y'
    la t5, input_buffer
    lb t4, (t5)                                # Read first character of response

    li s3, ASCII_START                         # Start of ASCII range
write_loop:
    li t5, ASCII_END                           # End of ASCII range
    bgt s3, t5, close_file                     # If reached end of range, close file
    addi t1, s3, -ASCII_START                  # Index for frequency array (character - 32)
    slli t1, t1, 2                             # Multiply by 4 (size of one element)
    la t0, frequency                           # Load address of frequency array into t0
    lw t2, 0(t0)                               # Get frequency of current character
    bne t2, zero, write_line                   # If frequency is non-zero, write
    addi s3, s3, 1                             # Move to next character
    j write_loop                                # Repeat loop

write_line:
    # Write string to output file
    write(a0, output_buffer, 8)                # Write 8 bytes (character + frequency)
    la t5, output_buffer                        # Load address of output_buffer into t5
    addi t5, t5, 8                              # Increment address by 8 bytes
    addi s3, s3, 1                              # Move to next character
    beq t4, t6, print_to_console                # If response is 'Y', go to print to console
    j write_loop                                 # Go back to loop if response is 'N'

print_to_console:
    # Print character and its frequency to console
    print_char(s3)                              # Print character to console
    print_string(": ")
    print_int(t2)                               # Print its frequency to console
    new_line                                     # Print a new line
    j write_loop                                 # Return to start of loop

close_file:
    close(a0)                                   # Close output file
    exit

# Error handling
file_open_error:
    print_string("Error opening file\n")
    exit

file_read_error:
    print_string("Error reading file\n")
    exit