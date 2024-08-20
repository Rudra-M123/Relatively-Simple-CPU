build:
	iverilog -o rscpu -c files.txt
	vvp -n rscpu -v "run; finish"
	gtkwave top_module.vcd

write:
	python hex_mem_write.py
	$(MAKE) build