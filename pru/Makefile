
#COMPILER=../../PASM/pasm -b 
COMPILER=pasm -b 
FILENAME1=p9_15
FILENAME2=p9_23

.PHONY: clean all

all:
	$(COMPILER) $(FILENAME1).p
	$(COMPILER) $(FILENAME2).p


clean: 
	rm -rf $(FILENAME1).bin
	rm -rf $(FILENAME2).bin


