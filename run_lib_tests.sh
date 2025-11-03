#!/bin/bash

# Create output directories if they don't exist
mkdir -p lib_out/asm
mkdir -p lib_out/stdout
mkdir -p lib_out/stderr
mkdir -p lib_out/parsetree
mkdir -p lib_out/symbol_table

# Clean and build the parser
make clean && clear && make

# Check if the parser was built successfully
if [ ! -f parser ]; then
    echo "Error: parser executable not found. Build failed."
    exit 1
fi


for file in lib/*.gs; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .gs)
        echo "Running parser for $file..."
        # Run the parser and redirect stdout and stderr
        ./parser "$file" > "lib_out/stdout/$filename.out" 2> "lib_out/stderr/$filename.err"
        
        # Check if code.asm was created and move it
        if [ -f "code.asm" ]; then
            mv "code.asm" "lib_out/asm/$filename.asm"
        else
            echo "Warning: code.asm not found for $file"
        fi

        # Check if parser_output.txt was created and move it
        if [ -f "parser_output.txt" ]; then
            mv "parser_output.txt" "lib_out/parsetree/$filename.txt"
        else
            echo "Warning: parser_output.txt not found for $file"
        fi

        # Check if symbol_table.txt was created and move it
        if [ -f "symbol_table.txt" ]; then
            mv "symbol_table.txt" "lib_out/symbol_table/$filename.txt"
        else
            echo "Warning: symbol_table.txt not found for $file"
        fi
    fi
done

echo "Checking for errors in stderr files..."
grep -ir "Error" lib_out/stderr/*


echo "Checking for warnings in stderr files..."
grep -ir "Warning" lib_out/stderr/*

echo "All files processed."
